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
    let center = CGPoint(x: 30.0, y: 30.0)
    let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let colorRed = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let colorBlue = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let combineMaskRect = CGRect(x: 11, y: -18, width: 4, height: 36)
    let tractorMaskRect = CGRect(x: -20, y: -9, width: 4, height: 18)
    
    let maskTexture: SKMutableTexture
    let spriteNode: SKSpriteNode
    
    init(size: CGSize) {
        self.maskTexture = SKMutableTexture(size: size)
        self.spriteNode = SKSpriteNode(texture: maskTexture)
        self.spriteNode.zPosition = 3
        self.spriteNode.color = SKColor.black

    }
    
    func generateBrushImage(rotation: CGFloat, color: CGColor, mask: CGRect) -> [UInt8] {
        let context = CGContext(data: nil, width: brushImageWidth, height: brushImageHeight,
                                bitsPerComponent: 8, bytesPerRow: brushImageWidth * 4,
                                space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.translateBy(x: self.center.x, y: self.center.y)
        context?.setFillColor(color)
        context?.rotate(by: -rotation) //why * -1 ?
        context?.fill(mask)
        
        let image = context?.makeImage()
        let data = image?.dataProvider?.data
        let ptr = CFDataGetBytePtr(data)
        let dataFromImage = Data(bytes: ptr!, count: CFDataGetLength(data))
        let count = dataFromImage.count / MemoryLayout<UInt8>.size
        var arrayOfBytesWithMask = [UInt8](repeating: 0, count: count)
        dataFromImage.copyBytes(to: &arrayOfBytesWithMask, count:count * MemoryLayout<UInt8>.size)
        return arrayOfBytesWithMask
    }
    
    func drawBrushAtPoint(point: CGPoint, arrayOfBytesWithMask: [UInt8]) {
        maskTexture.modifyPixelData({pixelData, lengthInBytes in
            let maskTextureWidth = Int(self.maskTexture.size().width)
            let indexInTextureArray = Int(point.y) * maskTextureWidth + Int(point.x)
            for brushX in 0..<self.brushImageWidth {
                for brushY in 0..<self.brushImageHeight {
                    let brushArrayIndex = (brushY * self.brushImageWidth + brushX) * 4
                    let pixelArray: [UInt8] = [arrayOfBytesWithMask[brushArrayIndex + 0],
                                           arrayOfBytesWithMask[brushArrayIndex + 1],
                                           arrayOfBytesWithMask[brushArrayIndex + 2],
                                           arrayOfBytesWithMask[brushArrayIndex + 3]]
                    var pixel: UInt32 = 0
                    if (pixelArray[3] == 0xFF) {
                        if (pixelArray[2] == 0xFF) {
                            pixel = 0xFFFF0000
                        } else if (pixelArray[0] == 0xFF) {
                            pixel = 0xFF0000FF
                        }
                    }
                    if (pixel != 0x00000000) {
                        let byteOffset = indexInTextureArray * 4 + brushX * 4 + brushY * 4 * maskTextureWidth
                        let originalValue = pixelData?.load(fromByteOffset: byteOffset, as: UInt32.self)
                        if (originalValue! == 0xFF0000FF && pixel == 0xFFFF0000) {
                            pixelData?.storeBytes(of: pixel, toByteOffset: byteOffset, as: UInt32.self)
                        } else if (originalValue! == 0 && (pixel == 0xFFFF0000 || pixel == 0xFF0000FF)) {
                            pixelData?.storeBytes(of: pixel, toByteOffset: byteOffset, as: UInt32.self)
                        }
                    }
                }
            }
        })
    }

    
}
