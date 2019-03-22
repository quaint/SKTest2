//
//  Field.swift
//  SKTest2
//
//  Created by Tomasz Wiśniewski on 21/03/2019.
//  Copyright © 2019 GlobalLogic. All rights reserved.
//

import Foundation
import SpriteKit

class Field {
    
    let blocksInRow = 50
    let blocksInColumn = 40
    let blockSize = 20
    let width: Int
    let height: Int
    
    let spriteNode: SKSpriteNode
    
    var fieldTexture: SKTexture?
    var fieldGroundTexture: SKTexture?
    var fieldDoneTexture: SKTexture?
    
    let view: SKView

    let field = SKNode()
    let fieldDone = SKNode()
    let fieldGround = SKNode()
    
    let mask: Mask

    init(view: SKView) {
        self.view = view
        self.width = blocksInRow * blockSize
        self.height = blocksInColumn * blockSize
        self.mask = Mask(size: CGSize(width: CGFloat(width),height: CGFloat(height)))
        for x in 0..<blocksInRow {
            for y in 0..<blocksInColumn {
                let fieldPart = SKSpriteNode(imageNamed: "field")
                fieldPart.position = CGPoint(x: x * blockSize, y: y * blockSize)
                field.addChild(fieldPart)
                
                let fieldDonePart = SKSpriteNode(imageNamed: "field_done")
                fieldDonePart.position = CGPoint(x: x * blockSize, y: y * blockSize)
                fieldDone.addChild(fieldDonePart)
                
                let fieldGroundPart = SKSpriteNode(imageNamed: "field_ground")
                fieldGroundPart.position = CGPoint(x: x * blockSize, y: y * blockSize)
                fieldGround.addChild(fieldGroundPart)
            }
        }
        fieldTexture = view.texture(from: field)
        fieldDoneTexture = view.texture(from: fieldDone)
        fieldGroundTexture = view.texture(from: fieldGround)
        
        self.spriteNode = SKSpriteNode(texture: fieldTexture)
        
        self.spriteNode.shader = SKShader(fileNamed: "field.fsh")
        let fieldDoneTextureUniform = SKUniform(name: "field_done", texture: fieldDoneTexture)
        let fieldGroundTextureUniform = SKUniform(name: "field_ground", texture: fieldGroundTexture)
        let fieldMaskTextureUniform = SKUniform(name: "mask", texture: mask.maskTexture)
        self.spriteNode.shader?.addUniform(fieldDoneTextureUniform)
        self.spriteNode.shader?.addUniform(fieldGroundTextureUniform)
        self.spriteNode.shader?.addUniform(fieldMaskTextureUniform)
        
        self.spriteNode.zPosition = -1
    }
    
    func update(spriteNode: SKSpriteNode, moveDirection: MoveDirection) {
        mask.update(spriteNode: spriteNode, moveDirection: moveDirection)
    }
}
