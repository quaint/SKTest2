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

    let bufferWidth = 60
    let bufferHeight = 60
    let center = CGPoint(x: 30.0, y: 30.0)
    let mask = CGRect(x: 11, y: -18, width: 4, height: 36)
    
    func generateMaskForMachine(rotation: CGFloat, color: CGColor) -> [UInt8] {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: bufferWidth, height: bufferHeight,
                                bitsPerComponent: 8, bytesPerRow: bufferWidth * 4,
                                space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.translateBy(x: self.center.x, y: self.center.y)
        context?.setFillColor(color)
        context?.rotate(by: -rotation) //why * -1 ?
        context?.fill(self.mask)
        
        let image = context?.makeImage()
        let data = image?.dataProvider?.data
        let ptr = CFDataGetBytePtr(data)
        let dataFromImage = Data(bytes: ptr!, count: CFDataGetLength(data))
        let count = dataFromImage.count / MemoryLayout<UInt8>.size
        var arrayOfBytesWithMask = [UInt8](repeating: 0, count: count)
        dataFromImage.copyBytes(to: &arrayOfBytesWithMask, count:count * MemoryLayout<UInt8>.size)
        return arrayOfBytesWithMask
    }
    
}
