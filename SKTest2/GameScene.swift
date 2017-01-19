//
//  GameScene.swift
//  SKTest2
//
//  Created by Tomasz Wiśniewski on 11/01/2017.
//  Copyright © 2017 GlobalLogic. All rights reserved.
//

import SpriteKit
import GameplayKit

enum MoveDirection: Int {
    case forward = 1
    case backward = -1
    case none = 0
}

enum RotateDirection: Int {
    case left = 1
    case right = -1
    case none = 0
}

class GameScene: SKScene {

    var mask: SKSpriteNode?
    var angle: Double = 0.0
    var array: [UInt8]?
    
    var combine: SKSpriteNode!
    var rotateDirection = RotateDirection.none
    var moveDirection = MoveDirection.none
    var previousTime: Double = 0
    let rotateSpeed: Double = 1
    let moveSpeed: Double = 50
    
    let field = SKNode()
    let fieldDone = SKNode()
    let fieldGround = SKNode()
    var fieldGroundTexture: SKTexture!
    var fieldDoneTexture: SKTexture!
    var fieldDoneNode: SKSpriteNode!
    var fieldNode: SKSpriteNode!
    
    let fieldContainer = SKNode()
    let gridSize = 20

    let bufferWidth = 40
    let bufferHeight = 40
    let maskWidth = 4
    let maskHeight = 40
    let maskAnchorX = 4
    let maskAnchorY = -20
    let maskDivider = 2
    
    let fieldBlocksWidth = 50
    let fieldBlocksHeight = 40
    
    var cam: SKCameraNode!
    
    var preview: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        cam = childNode(withName: "camera") as! SKCameraNode!
        
        for x in 0..<fieldBlocksWidth {
            for y in 0..<fieldBlocksHeight {
                let fieldPart = SKSpriteNode(imageNamed: "field")
                fieldPart.position = CGPoint(x: x * gridSize, y: y * gridSize)
                field.addChild(fieldPart)
                
                let fieldDonePart = SKSpriteNode(imageNamed: "field_done")
                fieldDonePart.position = CGPoint(x: x * gridSize, y: y * gridSize)
                fieldDone.addChild(fieldDonePart)
                
                let fieldGroundPart = SKSpriteNode(imageNamed: "field_ground")
                fieldGroundPart.position = CGPoint(x: x * gridSize, y: y * gridSize)
                fieldGround.addChild(fieldGroundPart)
            }
        }
        
        let fieldTexture = self.view?.texture(from: field)
        fieldNode = SKSpriteNode(texture: fieldTexture)
        fieldNode.zPosition = 0
        fieldContainer.addChild(fieldNode)
        
        let fieldBufferSizeWidth = fieldBlocksWidth * gridSize
        let fieldBufferSizeHeight = fieldBlocksHeight * gridSize
        
        fieldDoneTexture = self.view?.texture(from: fieldDone)
        fieldDoneNode = SKSpriteNode(texture: fieldDoneTexture)
        let crop = SKCropNode()
        mask = SKSpriteNode(texture: nil, size: CGSize(width: fieldBufferSizeWidth, height: fieldBufferSizeHeight))
        mask?.texture = SKMutableTexture(size: CGSize(width: CGFloat(fieldBufferSizeWidth/maskDivider),
                                                      height: CGFloat(fieldBufferSizeHeight/maskDivider)))
        crop.maskNode = mask
        crop.addChild(fieldDoneNode)
        crop.zPosition = 1
        fieldContainer.addChild(crop)
        self.addChild(fieldContainer)
        
        fieldGroundTexture = self.view?.texture(from: fieldGround)
        
        combine = SKSpriteNode(imageNamed:"combine")
        combine.zPosition = 2
        combine.anchorPoint = CGPoint(x: 0.65, y: 0.5)
        self.addChild(combine)
        
        preview = SKSpriteNode(texture: nil, size: CGSize(width: 200, height: 160))
        preview.position = CGPoint(x: -200, y: 200)
        preview.zPosition = 3
        self.addChild(preview)
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateKeyboardState()
        let delta = currentTime - previousTime
        let move = CGFloat(Double(moveDirection.rawValue) * delta * moveSpeed)
        let rotate = Double(rotateDirection.rawValue) * delta * rotateSpeed
        previousTime = currentTime
        combine.zRotation = combine.zRotation + CGFloat(rotate)
        combine.position = CGPoint(x: combine.position.x + cos(combine.zRotation) * move,
                                   y: combine.position.y + sin(combine.zRotation) * move)
        cam.position = combine.position
        if (moveDirection != .none || rotateDirection != .none) {
            updateMask()
            addPointOnMask(x: combine.position.x/CGFloat(maskDivider) + CGFloat(fieldBlocksWidth * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferWidth/2),
                           y: combine.position.y/CGFloat(maskDivider) + CGFloat(fieldBlocksHeight * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferHeight/2))
        }
        preview.texture = mask?.texture
    }

    func updateMask() {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: bufferWidth, height: bufferHeight, bitsPerComponent: 8, bytesPerRow: bufferWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.setFillColor(CGColor.black)
        context?.translateBy(x: CGFloat(bufferWidth/2), y: CGFloat(bufferHeight/2))
        context?.rotate(by: -combine.zRotation)
        context?.fill(CGRect(x: maskAnchorX, y: maskAnchorY, width: maskWidth, height: maskHeight))
        let image = context?.makeImage()
        let data = image?.dataProvider?.data
        let ptr = CFDataGetBytePtr(data)
        let dataFromImage = Data(bytes: ptr!, count: CFDataGetLength(data))
        let count = dataFromImage.count / MemoryLayout<UInt8>.size
        array = [UInt8](repeating: 0, count: count)
        dataFromImage.copyBytes(to: &array!, count:count * MemoryLayout<UInt8>.size)
    }
    
    func addPointOnMask(x: CGFloat, y: CGFloat) {
        let tex = mask?.texture as! SKMutableTexture
        tex.modifyPixelData({pixelData, lengthInBytes in
            if let arr = self.array {
                let pos = Int(y) * Int((self.mask?.texture?.size().width)!) + Int(x)
                for insideX in 0..<self.bufferWidth {
                    for insideY in 0..<self.bufferHeight {
                        let startIndex = (insideY * self.bufferWidth + insideX) * 4
                        let newArr: [UInt8] = [arr[startIndex + 0], arr[startIndex + 1], arr[startIndex + 2], arr[startIndex + 3]]
                        let pixel = UnsafePointer(newArr).withMemoryRebound(to: UInt32.self, capacity: 1) {
                            $0.pointee
                        }
                        if (pixel == 0xff000000) {
                            pixelData?.storeBytes(of: pixel, toByteOffset: pos * 4 + insideX * 4 + insideY * 4 * Int((self.mask?.texture?.size().width)!), as: UInt32.self)
                        }
                    }
                }
            }
        })
    }
    
    func switchGround(texture: SKTexture) {
        let wholeField = self.view?.texture(from: fieldContainer)
        fieldNode.texture = wholeField
        fieldDoneNode.texture = texture
        let emptyData = Data(bytes: [UInt8](repeating: 0, count: 500*400*4))
        mask?.texture = SKMutableTexture(size: CGSize(width: 500, height: 400))
    }
    
    func updateKeyboardState() {
        if (Keyboard.sharedKeyboard.justPressed(.up)) {
            moveDirection = .forward
        } else if (Keyboard.sharedKeyboard.justPressed(.down)) {
            moveDirection = .backward
        } else if (Keyboard.sharedKeyboard.justPressed(.left)) {
            rotateDirection = .left
        } else if (Keyboard.sharedKeyboard.justPressed(.right)) {
            rotateDirection = .right
        }
        
        if (Keyboard.sharedKeyboard.justReleased(.up, .down)) {
            moveDirection = .none
        }
        if (Keyboard.sharedKeyboard.justReleased(.left, .right)) {
            rotateDirection = .none
        }
        if (Keyboard.sharedKeyboard.justReleased(.one)) {
            switchGround(texture: fieldDoneTexture)
        }
        if (Keyboard.sharedKeyboard.justReleased(.two)) {
            switchGround(texture: fieldGroundTexture)
        }
    }
    
    override func didFinishUpdate() {
        Keyboard.sharedKeyboard.update()
    }
    
    override func keyUp(with theEvent: NSEvent) {
        Keyboard.sharedKeyboard.handleKey(theEvent, isDown: false)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        Keyboard.sharedKeyboard.handleKey(theEvent, isDown: true)
    }
}
