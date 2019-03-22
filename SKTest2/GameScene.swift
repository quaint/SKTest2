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

    var combine: Combine!
    var field: Field!
    
    var rotateDirection = RotateDirection.none
    var moveDirection = MoveDirection.none
    var activeMachine = ActiveMachine.combine
    var previousTime = 0.0
            
    var cam: SKCameraNode!
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        cam = childNode(withName: "camera") as! SKCameraNode?
        
        field = Field(view: view)
        self.addChild(field.spriteNode)
        
        combine = Combine(position: CGPoint(x: -200, y: 200))
        self.addChild(combine.spriteNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - previousTime
        previousTime = currentTime
        updateKeyboardState()
        switch activeMachine {
        case .combine:
            combine.update(delta: delta, moveDirection: moveDirection, rotateDirection: rotateDirection)
            cam.position = combine.spriteNode.position
            if (moveDirection != .none || rotateDirection != .none) {
                field.update(spriteNode: combine.spriteNode, moveDirection: moveDirection)
            }
        default:
            print("unknown machine type")
        }
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
