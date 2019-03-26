//
//  Combine.swift
//  SKTest2
//
//  Created by Tomasz Wiśniewski on 19/03/2019.
//  Copyright © 2019 GlobalLogic. All rights reserved.
//

import Foundation
import SpriteKit

class Combine {
    
    let rotateSpeed = 1.0
    let moveSpeed = 40.0
    
    let pouringSpeed = 100
    var grain = 0
    let maxGrain = 3000
    let maxFuel = 300
    var fuel: Double
    var workingTime = 0.0
    let defaultWorkingTime = 1000
    let workingSpeed = 1000.0
    
    var isProcessing: Bool {
        return workingTime > 0
    }

    let spriteNode: SKSpriteNode
    let strawAnim: SKSpriteNode
    
    init(position: CGPoint) {
        self.fuel = Double(maxFuel)
        
        self.spriteNode = SKSpriteNode(imageNamed:"combine")
        self.spriteNode.zPosition = 2
        self.spriteNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.spriteNode.physicsBody = SKPhysicsBody(rectangleOf: self.spriteNode.size)
        self.spriteNode.position = position
        
        self.strawAnim = SKSpriteNode(imageNamed: "strawAnim1")
        self.strawAnim.position = CGPoint(x: -40, y: 0)
        let textures = [SKTexture(imageNamed: "strawAnim1"), SKTexture(imageNamed: "strawAnim2")]
        let animate = SKAction.animate(with: textures, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(animate)
        strawAnim.run(repeatAnimation)
        self.spriteNode.addChild(strawAnim)
    }

    func update(delta: Double, moveDirection: MoveDirection, rotateDirection: RotateDirection) {
        if moveDirection != .none {
            if fuel > 0 {
                fuel -= delta
            } else {
                fuel = 0;
            }
        }
        if fuel > 0 {
            let move = CGFloat(Double(moveDirection.rawValue) * delta * moveSpeed)
            let rotate = CGFloat(Double(rotateDirection.rawValue) * delta * rotateSpeed)
            spriteNode.zRotation = spriteNode.zRotation + rotate
            spriteNode.position = CGPoint(x: spriteNode.position.x + cos(spriteNode.zRotation) * move,
                                          y: spriteNode.position.y + sin(spriteNode.zRotation) * move)
            
            if workingTime > 0 {
                workingTime -= delta * workingSpeed
            }
        }
    }
    
}
