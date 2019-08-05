//
//  Mask.swift
//  SKTest2
//
//  Created by Tomasz Wiśniewski on 19/03/2019.
//  Copyright © 2019 GlobalLogic. All rights reserved.
//

import Foundation
import SpriteKit

class Mask {

    let brushImageWidth = 60
    let brushImageHeight = 60
    let brushImageCenter: CGPoint
    
    let divider: CGFloat = 2.0

    let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    let colorRed = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let colorBlue = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    
    let headerBrush = CGRect(x: 12, y: -20, width: 4, height: 39)
    let strawBrush = CGRect(x: -20, y: -9, width: 4, height: 18)
    
    let maskTexture: SKMutableTexture
    let spriteNode: SKSpriteNode
    let width: CGFloat
    let height: CGFloat
    let shiftFromPositionHorizontal: CGFloat
    let shiftFromPositionVertical: CGFloat
    
    init(size: CGSize) {
        width = size.width
        height = size.height
        shiftFromPositionHorizontal = width / (2 * divider)
        shiftFromPositionVertical = height / (2 * divider)
        brushImageCenter = CGPoint(x: CGFloat(brushImageWidth) / 2,
                                   y: CGFloat(brushImageHeight) / 2)
        maskTexture = SKMutableTexture(size: CGSize(width: width/divider,
                                                    height: height/divider))
        spriteNode = SKSpriteNode(texture: maskTexture)
        spriteNode.zPosition = 3
        spriteNode.color = SKColor.black
    }
    
    func generateBrushImage(rotation: CGFloat, color: CGColor, brush: CGRect) -> [UInt8] {
        let context = CGContext(data: nil, width: brushImageWidth, height: brushImageHeight,
                                bitsPerComponent: 8, bytesPerRow: brushImageWidth * 4,
                                space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.translateBy(x: self.brushImageCenter.x, y: self.brushImageCenter.y)
        context?.setFillColor(color)
        context?.rotate(by: -rotation) //why * -1 ?
        context?.fill(brush)
        
        let image = context?.makeImage()
        let data = image?.dataProvider?.data
        let ptr = CFDataGetBytePtr(data)
        let dataFromImage = Data(bytes: ptr!, count: CFDataGetLength(data))
        let count = dataFromImage.count / MemoryLayout<UInt8>.size
        var arrayOfBytesWithMask = [UInt8](repeating: 0, count: count)
        dataFromImage.copyBytes(to: &arrayOfBytesWithMask, count:count * MemoryLayout<UInt8>.size)
        return arrayOfBytesWithMask
    }
    
    func drawOnTexture(point: CGPoint, brush: [UInt8]) -> Int {
        var modifiedPixels = 0
        maskTexture.modifyPixelData({pixelData, lengthInBytes in
            let maskTextureWidth = Int(self.maskTexture.size().width)
            let indexInTextureArray = Int(point.y - self.brushImageCenter.y) * maskTextureWidth
                + Int(point.x - self.brushImageCenter.x)
            for brushX in 0..<self.brushImageWidth {
                for brushY in 0..<self.brushImageHeight {
                    let brushArrayIndex = (brushY * self.brushImageWidth + brushX) * 4
                    let pixelArray: [UInt8] = [brush[brushArrayIndex + 0], //red
                                           brush[brushArrayIndex + 1], // green
                                           brush[brushArrayIndex + 2], // blue
                                           brush[brushArrayIndex + 3]] //alpha
                    var pixel: UInt32 = 0
                    if (pixelArray[3] == 0xFF) { //alpha
                        if (pixelArray[2] == 0xFF) { //blue
                            pixel = 0xFFFF0000
                        } else if (pixelArray[0] == 0xFF) { // red
                            pixel = 0xFF0000FF
                        }
                    }
                    if (pixel != 0x00000000) {
                        let byteOffset = indexInTextureArray * 4 + brushX * 4 + brushY * 4 * maskTextureWidth
                        let originalValue = pixelData?.load(fromByteOffset: byteOffset, as: UInt32.self)
                        if (originalValue! == 0xFF0000FF && pixel == 0xFFFF0000) { //blue on red
                            pixelData?.storeBytes(of: pixel, toByteOffset: byteOffset, as: UInt32.self)
                        } else if (originalValue! == 0 && pixel == 0xFF0000FF) { // red on nothing
                            pixelData?.storeBytes(of: pixel, toByteOffset: byteOffset, as: UInt32.self)
                            modifiedPixels += 1
                        }
                    }
                }
            }
        })
        return modifiedPixels
    }

    func nodePointToTexturePoint(position: CGPoint) -> CGPoint {
        return CGPoint(x: position.x / divider + shiftFromPositionHorizontal,
                       y: position.y / divider + shiftFromPositionVertical)
    }
    
    func update(spriteNode: SKSpriteNode, moveDirection: MoveDirection, processing: Bool) -> Int {
        var modifiedPixels = 0
        if moveDirection == .forward {
            let headerBrushImage = generateBrushImage(rotation: spriteNode.zRotation, color: colorRed,
                                            brush: headerBrush)
            modifiedPixels = drawOnTexture(point: nodePointToTexturePoint(position: spriteNode.position),
                          brush: headerBrushImage)
        }
        if processing {
            let strawBrushImage = generateBrushImage(rotation: spriteNode.zRotation, color: colorBlue,
                                                brush: strawBrush)
            _ = drawOnTexture(point: nodePointToTexturePoint(position: spriteNode.position),
                          brush: strawBrushImage)
        }
        return modifiedPixels
    }
    
}
