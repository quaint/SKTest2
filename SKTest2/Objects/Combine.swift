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

    let spriteNode: SKSpriteNode
    let strawAnim: SKSpriteNode
    
    init(position: CGPoint) {
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
        let move = CGFloat(Double(moveDirection.rawValue) * delta * moveSpeed)
        let rotate = CGFloat(Double(rotateDirection.rawValue) * delta * rotateSpeed)
        spriteNode.zRotation = spriteNode.zRotation + rotate
        spriteNode.position = CGPoint(x: spriteNode.position.x + cos(spriteNode.zRotation) * move,
                                      y: spriteNode.position.y + sin(spriteNode.zRotation) * move)
    }
    
}
