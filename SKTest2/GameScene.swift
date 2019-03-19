//
//  GameScene.swift
//  SKTest2
//
//  Created by Tomasz Wiśniewski on 11/01/2017.
//  Copyright © 2017 GlobalLogic. All rights reserved.
//

import SpriteKit

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

enum ActiveMachine {
    case combine
    case tractor
    case tractorTwo
}

class GameScene: SKScene {

    var arrayOfBytesWithMask: [UInt8]?
    var mask: SKSpriteNode?
    
    var combine: SKSpriteNode!
    var strawAnim: SKSpriteNode!
    
    var tractorOne: SKSpriteNode!
    var tractorTwo: SKSpriteNode!
    
    var trailerOne: SKSpriteNode!
    var trailerTwo: SKSpriteNode!
    
    var rotateDirection = RotateDirection.none
    var moveDirection = MoveDirection.none
    var activeMachine = ActiveMachine.combine
    var previousTime = 0.0
    let rotateSpeed = 1.0
    let moveSpeed = 40.0
    
    let field = SKNode()
    let fieldDone = SKNode()
    let fieldGround = SKNode()
    
    var fieldGroundTexture: SKTexture!
    var fieldDoneTexture: SKTexture!
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
    
    let maskTwoWidth = 4
    let maskTwoHeight = 18
    let maskTwoAnchorX = -20
    let maskTwoAnchorY = -9
    
    let maskDivider = 2
    
    let fieldBlocksWidth = 50
    let fieldBlocksHeight = 40
    
    var cam: SKCameraNode!
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        cam = childNode(withName: "camera") as! SKCameraNode?
        
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
        fieldNode.zPosition = -1
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
        
        mask = SKSpriteNode(texture: maskTexture)
//        mask?.position = CGPoint(x: -10, y: -10)
        mask?.zPosition = 3
        mask?.color = SKColor.black
//        self.addChild(mask!)
        
        combine = SKSpriteNode(imageNamed:"combine")
        combine.zPosition = 2
        combine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        combine.physicsBody = SKPhysicsBody(rectangleOf: combine.size)
        combine.position = CGPoint(x: -200, y: 200)
        self.addChild(combine)
        
        tractorOne = SKSpriteNode(imageNamed:"tractor")
        tractorOne.zPosition = 2
        tractorOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tractorOne.physicsBody = SKPhysicsBody(rectangleOf: tractorOne.size)
        tractorOne.physicsBody?.angularDamping = 0.3
        tractorOne.physicsBody?.linearDamping = 0.15
        tractorOne.physicsBody?.friction = 0.3
        tractorOne.physicsBody?.restitution = 0.4
        tractorOne.physicsBody?.density = 1.0
//        tractorOne.physicsBody?.mass = 50.0
        tractorOne.position = CGPoint(x: 120, y: 120)
        self.addChild(tractorOne)
        
        tractorTwo = SKSpriteNode(imageNamed:"tractor")
        tractorTwo.zPosition = 2
        tractorTwo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tractorTwo.physicsBody = SKPhysicsBody(rectangleOf: tractorOne.size)
        tractorTwo.physicsBody?.angularDamping = 5.0
        tractorTwo.physicsBody?.linearDamping = 5.0
//        tractorTwo.physicsBody?.mass = 1.0
//        tractorTwo.physicsBody?.friction = 100.0
        tractorTwo.position = CGPoint(x: 220, y: 120)
        self.addChild(tractorTwo)
        
        trailerOne = SKSpriteNode(imageNamed:"trailer")
        trailerOne.zPosition = 2
        trailerOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trailerOne.physicsBody = SKPhysicsBody(rectangleOf: trailerOne.size)
        trailerOne.physicsBody?.angularDamping = 25.0
        trailerOne.physicsBody?.linearDamping = 5.0
//        trailerOne.physicsBody?.friction = 100.0
//        trailerOne.physicsBody?.restitution = 10.0
//        trailerOne.physicsBody?.mass = 1.0
        trailerOne.position = CGPoint(x: 76, y: 120)
        self.addChild(trailerOne)
        
        let pinJoint = SKPhysicsJointPin.joint(withBodyA: tractorOne.physicsBody!,
                                               bodyB: trailerOne.physicsBody!,
                                               anchor: CGPoint(x: tractorOne.position.x -
                                                tractorOne.size.width/2, y: tractorOne.position.y))
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
//        trailerTwo.position = CGPoint(x: trailerOne.position.x-trailerOne.size.width/2-trailerTwo.size.width/2, y: trailerOne.position.y)
        self.addChild(trailerTwo)
        
//        let pinJointTwo = SKPhysicsJointPin.joint(withBodyA: trailerOne.physicsBody!,
//                                               bodyB: trailerTwo.physicsBody!,
//                                               anchor: CGPoint(x: trailerOne.position.x - trailerOne.size.width/2, y: trailerOne.position.y))
//        pinJointTwo.shouldEnableLimits = true
//        pinJointTwo.upperAngleLimit = CGFloat.pi/4
//        pinJointTwo.lowerAngleLimit = -CGFloat.pi/4
//        self.physicsWorld.add(pinJointTwo)
        
        strawAnim = SKSpriteNode(imageNamed: "strawAnim1")
        strawAnim.position = CGPoint(x: -40, y: 0)
        let textures = [SKTexture(imageNamed: "strawAnim1"), SKTexture(imageNamed: "strawAnim2")]
        let animate = SKAction.animate(with: textures, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(animate)
        strawAnim.run(repeatAnimation)
        combine.addChild(strawAnim)
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
//            tractorOne.zRotation = tractorOne.zRotation + CGFloat(rotate)
//            tractorOne.position = CGPoint(x: tractorOne.position.x + cos(tractorOne.zRotation) * move,
//                                          y: tractorOne.position.y + sin(tractorOne.zRotation) * move)
            let rotation = tractorOne.zRotation + CGFloat(Double(rotateDirection.rawValue) * 0.05)
//            tractorOne.position = CGPoint(x: tractorOne.position.x + cos(tractorOne.zRotation) * move,
//                                       y: tractorOne.position.y + sin(tractorOne.zRotation) * move)
            if (moveDirection == .forward) {
                tractorOne.physicsBody?.velocity = CGVector(dx: cos(rotation) * CGFloat(moveSpeed),
                                                            dy: sin(rotation) * CGFloat(moveSpeed))
                let angle = atan2(sin(rotation), cos(rotation))
                tractorOne.zRotation = angle
            } else if (moveDirection == .backward) {
                tractorOne.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
            cam.position = tractorOne.position
        case .tractorTwo:
            tractorTwo.zRotation = tractorTwo.zRotation + CGFloat(rotate)
            tractorTwo.position = CGPoint(x: tractorTwo.position.x + cos(tractorTwo.zRotation) * move,
                                       y: tractorTwo.position.y + sin(tractorTwo.zRotation) * move)
            cam.position = tractorTwo.position
            if (moveDirection != .none || rotateDirection != .none) {
                updateMask()
                addPointOnMask(x: tractorTwo.position.x/CGFloat(maskDivider) + CGFloat(fieldBlocksWidth * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferWidth/2),
                               y: tractorTwo.position.y/CGFloat(maskDivider) + CGFloat(fieldBlocksHeight * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferHeight/2))
            }
        }
    }

    func updateMask() {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: bufferWidth, height: bufferHeight, bitsPerComponent: 8, bytesPerRow: bufferWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.translateBy(x: CGFloat(bufferWidth/2), y: CGFloat(bufferHeight/2))
        switch activeMachine {
        case .combine:
            context?.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
            context?.rotate(by: -combine.zRotation)
            context?.fill(CGRect(x: maskAnchorX, y: maskAnchorY, width: maskWidth, height: maskHeight))
        case .tractor:
            context?.setFillColor(CGColor(red: 0, green: 1, blue: 0, alpha: 1))
            context?.rotate(by: -tractorOne.zRotation)
            context?.fill(CGRect(x: maskAnchorX, y: maskAnchorY, width: maskWidth, height: maskHeight))
        case .tractorTwo:
            context?.setFillColor(CGColor(red: 0, green: 0, blue: 1, alpha: 1))
            context?.rotate(by: -tractorTwo.zRotation)
            context?.fill(CGRect(x: maskTwoAnchorX, y: maskTwoAnchorY, width: maskTwoWidth, height: maskTwoHeight))
        }
        let image = context?.makeImage()
        let data = image?.dataProvider?.data
        let ptr = CFDataGetBytePtr(data)
        let dataFromImage = Data(bytes: ptr!, count: CFDataGetLength(data))
        let count = dataFromImage.count / MemoryLayout<UInt8>.size
        arrayOfBytesWithMask = [UInt8](repeating: 0, count: count)
        dataFromImage.copyBytes(to: &arrayOfBytesWithMask!, count:count * MemoryLayout<UInt8>.size)
    }
    
    func addPointOnMask(x: CGFloat, y: CGFloat) {
        maskTexture.modifyPixelData({pixelData, lengthInBytes in
            if let arr = self.arrayOfBytesWithMask {
                let pos = Int(y) * Int(self.maskTexture.size().width) + Int(x)
                for insideX in 0..<self.bufferWidth {
                    for insideY in 0..<self.bufferHeight {
                        let startIndex = (insideY * self.bufferWidth + insideX) * 4
                        let newArr: [UInt8] = [arr[startIndex + 0], arr[startIndex + 1], arr[startIndex + 2], arr[startIndex + 3]]
                        var pixel: UInt32 = 0
                        if (newArr[3] == 0xFF) {
                            if (newArr[2] == 0xFF) {
                                pixel = 0xFFFF0000
                            } else if (newArr[0] == 0xFF) {
                                pixel = 0xFF0000FF
                            }
                        }
//                        let pixel = UnsafePointer(newArr).withMemoryRebound(to: UInt32.self, capacity: 1) {
//                            $0.pointee
//                        }
                        if (pixel != 0x00000000) {
                            let byteOffset = pos * 4 + insideX * 4 + insideY * 4 * Int(self.maskTexture.size().width)
                            let originalValue = pixelData?.load(fromByteOffset: byteOffset, as: UInt32.self)
//                            print("\(String(format: "%X", originalValue!))")
//                            print("\(String(format: "%X", pixel))")
//                            print("-----------")
                            if (originalValue! == 0xFF0000FF && pixel == 0xFFFF0000) {
                                pixelData?.storeBytes(of: pixel, toByteOffset: byteOffset, as: UInt32.self)
                            } else if (originalValue! == 0 && (pixel == 0xFFFF0000 || pixel == 0xFF0000FF)) {
                                pixelData?.storeBytes(of: pixel, toByteOffset: byteOffset, as: UInt32.self)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func switchMachine() {
        switch activeMachine {
        case .combine:
            activeMachine = .tractor
        case .tractor:
            activeMachine = .tractorTwo
        case .tractorTwo:
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
