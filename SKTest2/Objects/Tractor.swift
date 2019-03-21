////
////  Tractor.swift
////  SKTest2
////
////  Created by Tomasz Wiśniewski on 21/03/2019.
////  Copyright © 2019 GlobalLogic. All rights reserved.
////
//
//import Foundation
//
//tractorOne = SKSpriteNode(imageNamed:"tractor")
//tractorOne.zPosition = 2
//tractorOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//tractorOne.physicsBody = SKPhysicsBody(rectangleOf: tractorOne.size)
//tractorOne.physicsBody?.angularDamping = 0.3
//tractorOne.physicsBody?.linearDamping = 0.15
//tractorOne.physicsBody?.friction = 0.3
//tractorOne.physicsBody?.restitution = 0.4
//tractorOne.physicsBody?.density = 1.0
//tractorOne.position = CGPoint(x: 120, y: 120)
//self.addChild(tractorOne)
//
//tractorTwo = SKSpriteNode(imageNamed:"tractor")
//tractorTwo.zPosition = 2
//tractorTwo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//tractorTwo.physicsBody = SKPhysicsBody(rectangleOf: tractorOne.size)
//tractorTwo.physicsBody?.angularDamping = 5.0
//tractorTwo.physicsBody?.linearDamping = 5.0
//tractorTwo.position = CGPoint(x: 220, y: 120)
//self.addChild(tractorTwo)
//
//trailerOne = SKSpriteNode(imageNamed:"trailer")
//trailerOne.zPosition = 2
//trailerOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//trailerOne.physicsBody = SKPhysicsBody(rectangleOf: trailerOne.size)
//trailerOne.physicsBody?.angularDamping = 25.0
//trailerOne.physicsBody?.linearDamping = 5.0
//trailerOne.position = CGPoint(x: 76, y: 120)
//self.addChild(trailerOne)
//
//let pinJoint = SKPhysicsJointPin.joint(withBodyA: tractorOne.physicsBody!,
//                                       bodyB: trailerOne.physicsBody!,
//                                       anchor: CGPoint(x: tractorOne.position.x -
//                                        tractorOne.size.width/2, y: tractorOne.position.y))
//pinJoint.shouldEnableLimits = true
//pinJoint.upperAngleLimit = CGFloat.pi/4
//pinJoint.lowerAngleLimit = -CGFloat.pi/4
//self.physicsWorld.add(pinJoint)
//
//trailerTwo = SKSpriteNode(imageNamed:"trailer")
//trailerTwo.zPosition = 2
//trailerTwo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//trailerTwo.physicsBody = SKPhysicsBody(rectangleOf: trailerTwo.size)
//trailerTwo.physicsBody?.angularDamping = 1.0
//trailerTwo.physicsBody?.linearDamping = 1.0
//trailerTwo.physicsBody?.mass = 150.0
//self.addChild(trailerTwo)
//
//
//case .tractor:
//let rotation = tractorOne.zRotation + CGFloat(Double(rotateDirection.rawValue) * 0.05)
//if (moveDirection == .forward) {
//    tractorOne.physicsBody?.velocity = CGVector(dx: cos(rotation) * CGFloat(moveSpeed),
//                                                dy: sin(rotation) * CGFloat(moveSpeed))
//    let angle = atan2(sin(rotation), cos(rotation))
//    tractorOne.zRotation = angle
//} else if (moveDirection == .backward) {
//    tractorOne.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//}
//cam.position = tractorOne.position
//case .tractorTwo:
//tractorTwo.zRotation = tractorTwo.zRotation + CGFloat(rotate)
//tractorTwo.position = CGPoint(x: tractorTwo.position.x + cos(tractorTwo.zRotation) * move,
//y: tractorTwo.position.y + sin(tractorTwo.zRotation) * move)
//cam.position = tractorTwo.position
//if (moveDirection != .none || rotateDirection != .none) {
//let brushImage = maskObject?.generateBrushImage(rotation: tractorTwo.zRotation, color: maskObject!.colorBlue, mask: maskObject!.tractorMaskRect)
//let tractorTwoX = tractorTwo.position.x/CGFloat(maskDivider) + CGFloat(fieldBlocksWidth * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferWidth/2)
//let tractorTwoY = tractorTwo.position.y/CGFloat(maskDivider) + CGFloat(fieldBlocksHeight * gridSize)/CGFloat(2*maskDivider) - CGFloat(bufferHeight/2)
//let tractorTwoPoint = CGPoint(x: tractorTwoX, y: tractorTwoY)
//maskObject?.drawBrushAtPoint(point: tractorTwoPoint, arrayOfBytesWithMask: brushImage!)
//}
