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
    
    let fieldBlocksWidth = 50
    let fieldBlocksHeight = 40
    let gridSize = 20
    let maskDivider: CGFloat = 2.0
    
    let spriteNode: SKSpriteNode
    
    var fieldTexture: SKTexture?
    var fieldGroundTexture: SKTexture?
    var fieldDoneTexture: SKTexture?
    
    let view: SKView

    let field = SKNode()
    let fieldDone = SKNode()
    let fieldGround = SKNode()
    
    let maskObject: Mask

    init(view: SKView) {
        self.view = view
        self.maskObject = Mask(size: CGSize(width: CGFloat(fieldBlocksWidth * gridSize),
                                            height: CGFloat(fieldBlocksHeight * gridSize)))
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
        fieldTexture = view.texture(from: field)
        fieldDoneTexture = view.texture(from: fieldDone)
        fieldGroundTexture = view.texture(from: fieldGround)
        self.spriteNode = SKSpriteNode(texture: fieldTexture)
        self.spriteNode.shader = SKShader(fileNamed: "field.fsh")
        let fieldDoneTextureUniform = SKUniform(name: "field_done", texture: fieldDoneTexture)
        let fieldGroundTextureUniform = SKUniform(name: "field_ground", texture: fieldGroundTexture)
        let fieldMaskTextureUniform = SKUniform(name: "mask", texture: maskObject.maskTexture)
        self.spriteNode.shader?.addUniform(fieldDoneTextureUniform)
        self.spriteNode.shader?.addUniform(fieldGroundTextureUniform)
        self.spriteNode.shader?.addUniform(fieldMaskTextureUniform)
        self.spriteNode.zPosition = -1
    }
    
    func update(spriteNode: SKSpriteNode) {
        let nodeX = spriteNode.position.x / maskDivider
            + CGFloat(fieldBlocksWidth * gridSize) / (2 * maskDivider)
            - CGFloat(maskObject.brushImageWidth / 2)
        let nodeY = spriteNode.position.y / maskDivider
            + CGFloat(fieldBlocksHeight * gridSize) / (2 * maskDivider)
            - CGFloat(maskObject.brushImageHeight / 2)
        let brushImage = maskObject.generateBrushImage(rotation: spriteNode.zRotation,
                                                       color: maskObject.colorRed,
                                                       mask: maskObject.combineMaskRect)
        maskObject.drawBrushAtPoint(point: CGPoint(x: nodeX, y: nodeY),
                                    arrayOfBytesWithMask: brushImage)
    }
}
