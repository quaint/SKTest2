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
    
    let maskTexture: SKMutableTexture
    
    init(texture: SKMutableTexture) {
        self.maskTexture = texture
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
    
    func addPointOnMask(point: CGPoint, arrayOfBytesWithMask: [UInt8]) {
        maskTexture.modifyPixelData({pixelData, lengthInBytes in
            let indexInArray = Int(point.y) * Int(self.maskTexture.size().width) + Int(point.x)
            for insideX in 0..<self.brushImageWidth {
                for insideY in 0..<self.brushImageHeight {
                    let insideIndex = (insideY * self.brushImageWidth + insideX) * 4
                    let pixelArray: [UInt8] = [arrayOfBytesWithMask[insideIndex + 0],
                                           arrayOfBytesWithMask[insideIndex + 1],
                                           arrayOfBytesWithMask[insideIndex + 2],
                                           arrayOfBytesWithMask[insideIndex + 3]]
                    var pixel: UInt32 = 0
                    if (pixelArray[3] == 0xFF) {
                        if (pixelArray[2] == 0xFF) {
                            pixel = 0xFFFF0000
                        } else if (pixelArray[0] == 0xFF) {
                            pixel = 0xFF0000FF
                        }
                    }
                    if (pixel != 0x00000000) {
                        let byteOffset = indexInArray * 4 + insideX * 4 + insideY * 4 * Int(self.maskTexture.size().width)
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
