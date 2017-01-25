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

enum ActiveMachine: Int {
    case combine
    case tractor
}

class GameScene: SKScene {

    var mask: SKSpriteNode?
    var angle: Double = 0.0
    var array: [UInt8]?
    
    var combine: SKSpriteNode!
    var tractor: SKSpriteNode!
    var trailerOne: SKSpriteNode!
    var trailerTwo: SKSpriteNode!
    
    var rotateDirection = RotateDirection.none
    var moveDirection = MoveDirection.none
    var activeMachine = ActiveMachine.combine
    var previousTime: Double = 0
    let rotateSpeed: Double = 1
    let moveSpeed: Double = 50
    
    let field = SKNode()
    let fieldDone = SKNode()
    let fieldGround = SKNode()
    
    var fieldGroundTexture: SKTexture!
    var fieldDoneTexture: SKTexture!
    var fieldMaskTexture: SKTexture!
    var maskTexture: SKMutableTexture!
    
    var fieldDoneNode: SKSpriteNode!
    var fieldNode: SKSpriteNode!
    
    let gridSize = 20

    let bufferWidth = 60
    let bufferHeight = 60
    let maskWidth = 4
    let maskHeight = 36
    let maskAnchorX = 11
    let maskAnchorY = -18
    let maskDivider = 2
    
    let fieldBlocksWidth = 50
    let fieldBlocksHeight = 40
    
    var cam: SKCameraNode!
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
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
        self.addChild(fieldNode)
        
        fieldDoneTexture = self.view?.texture(from: fieldDone)
        fieldGroundTexture = self.view?.texture(from: fieldGround)

        let fieldBufferSizeWidth = fieldBlocksWidth * gridSize
        let fieldBufferSizeHeight = fieldBlocksHeight * gridSize

        maskTexture = SKMutableTexture(size: CGSize(width: CGFloat(fieldBufferSizeWidth/maskDivider),
                                                      height: CGFloat(fieldBufferSizeHeight/maskDivider)))
        
        fieldNode.shader = SKShader(fileNamed: "field.fsh")
        let fieldDoneTextureUniform = SKUniform(name: "field_done", texture: fieldDoneTexture)
        let fieldGroundTextureUniform = SKUniform(name: "field_ground", texture: fieldGroundTexture)
        let fieldMaskTextureUniform = SKUniform(name: "mask", texture: maskTexture)
        fieldNode.shader?.addUniform(fieldDoneTextureUniform)
        fieldNode.shader?.addUniform(fieldGroundTextureUniform)
        fieldNode.shader?.addUniform(fieldMaskTextureUniform)
        
        combine = SKSpriteNode(imageNamed:"combine")
        combine.zPosition = 2
        combine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        combine.physicsBody = SKPhysicsBody(rectangleOf: combine.size)
        combine.position = CGPoint(x: -200, y: 200)
        self.addChild(combine)
        
        tractor = SKSpriteNode(imageNamed:"tractor")
        tractor.zPosition = 2
        tractor.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tractor.physicsBody = SKPhysicsBody(rectangleOf: tractor.size)
        tractor.physicsBody?.angularDamping = 1.0
        tractor.physicsBody?.linearDamping = 1.0
        tractor.physicsBody?.mass = 50.0
        tractor.position = CGPoint(x: 120, y: 120)
        self.addChild(tractor)
        
        trailerOne = SKSpriteNode(imageNamed:"trailer")
        trailerOne.zPosition = 2
        trailerOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trailerOne.physicsBody = SKPhysicsBody(rectangleOf: trailerOne.size)
        trailerOne.physicsBody?.angularDamping = 1.0
        trailerOne.physicsBody?.linearDamping = 1.0
        trailerOne.physicsBody?.mass = 150.0
        trailerOne.position = CGPoint(x: tractor.position.x-tractor.size.width/2-trailerOne.size.width/2, y: tractor.position.y)
        self.addChild(trailerOne)
        
        let pinJoint = SKPhysicsJointPin.joint(withBodyA: tractor.physicsBody!,
                                               bodyB: trailerOne.physicsBody!,
                                               anchor: CGPoint(x: tractor.position.x - tractor.size.width/2, y: tractor.position.y))
        pinJoint.shouldEnableLimits = true
        pinJoint.upperAngleLimit = CGFloat.pi/4
        pinJoint.lowerAngleLimit = -CGFloat.pi/4
        self.physicsWorld.add(pinJoint)
        
        trailerTwo = SKSpriteNode(imageNamed:"trailer")
        trailerTwo.zPosition = 2
        trailerTwo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trailerTwo.physicsBody = SKPhysicsBody(rectangleOf: trailerTwo.size)
        trailerTwo.physicsBody?.angularDamping = 1.0
        trailerTwo.physicsBody?.linearDamping = 1.0
        trailerTwo.physicsBody?.mass = 150.0
        trailerTwo.position = CGPoint(x: trailerOne.position.x-trailerOne.size.width/2-trailerTwo.size.width/2, y: trailerOne.position.y)
        self.addChild(trailerTwo)
        
        let pinJointTwo = SKPhysicsJointPin.joint(withBodyA: trailerOne.physicsBody!,
                                               bodyB: trailerTwo.physicsBody!,
                                               anchor: CGPoint(x: trailerOne.position.x - trailerOne.size.width/2, y: trailerOne.position.y))
        pinJointTwo.shouldEnableLimits = true
        pinJointTwo.upperAngleLimit = CGFloat.pi/4
        pinJointTwo.lowerAngleLimit = -CGFloat.pi/4
//        self.physicsWorld.add(pinJointTwo)
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateKeyboardState()
        let delta = currentTime - previousTime
        let move = CGFloat(Double(moveDirection.rawValue) * delta * moveSpeed)
        let rotate = Double(rotateDirection.rawValue) * delta * rotateSpeed
        previousTime = currentTime
        switch activeMachine {
        case .combine:
            combine.zRotation = combine.zRotation + CGFloat(rotate)
            combine.position = CGPoint(x: combine.position.x + cos(combine.zRotation) * move,
                                       y: combine.position.y + sin(combine.zRotation) * move)
            cam.position = combine.position
            if (moveDirection != .none || rotateDirection != .none) {
                updateMask()
                addPointOnMask(x: combine.position.x/CGFloat(maskDivider) + CGFloat(fieldBlocksWidth * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferWidth/2),
                               y: combine.position.y/CGFloat(maskDivider) + CGFloat(fieldBlocksHeight * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferHeight/2))
            }
        case .tractor:
            let rotation = tractor.zRotation + CGFloat(rotate)
//            tractor.position = CGPoint(x: tractor.position.x + cos(tractor.zRotation) * move,
//                                       y: tractor.position.y + sin(tractor.zRotation) * move)
            if (moveDirection == .forward) {
                tractor.physicsBody?.velocity = CGVector(dx: cos(rotation) * 40, dy: sin(rotation) * 40)
                let angle = atan2(tractor.physicsBody!.velocity.dy, tractor.physicsBody!.velocity.dx)
                tractor.zRotation = angle
            } else if (moveDirection == .backward) {
                tractor.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
            cam.position = tractor.position
        }
    }

    func updateMask() {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: bufferWidth, height: bufferHeight, bitsPerComponent: 8, bytesPerRow: bufferWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        switch activeMachine {
        case .combine:
            context?.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        case .tractor:
            context?.setFillColor(CGColor(red: 0, green: 1, blue: 0, alpha: 1))
        }
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
        maskTexture.modifyPixelData({pixelData, lengthInBytes in
            if let arr = self.array {
                let pos = Int(y) * Int(self.maskTexture.size().width) + Int(x)
                for insideX in 0..<self.bufferWidth {
                    for insideY in 0..<self.bufferHeight {
                        let startIndex = (insideY * self.bufferWidth + insideX) * 4
                        let newArr: [UInt8] = [arr[startIndex + 0], arr[startIndex + 1], arr[startIndex + 2], arr[startIndex + 3]]
                        let pixel = UnsafePointer(newArr).withMemoryRebound(to: UInt32.self, capacity: 1) {
                            $0.pointee
                        }
                        if (pixel != 0x00000000) {
                            pixelData?.storeBytes(of: pixel, toByteOffset: pos * 4 + insideX * 4 + insideY * 4 * Int(self.maskTexture.size().width), as: UInt32.self)
                        }
                    }
                }
            }
        })
    }
    
    func switchMachine() {
        if (activeMachine == .combine) {
            activeMachine = .tractor
        } else {
            activeMachine = .combine
        }
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
            switchMachine()
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
