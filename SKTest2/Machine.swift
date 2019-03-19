//
//  Machine.swift
//  SKTest2
//
//  Created by Tomasz Wiśniewski on 19/03/2019.
//  Copyright © 2019 GlobalLogic. All rights reserved.
//

import Foundation
import SpriteKit

class Machine {
    
    enum MachineType {
        case combine
        case tractor
        case tractorTwo
    }
    
    let type: MachineType
    let node: SKSpriteNode
    
    init(type: MachineType, node: SKSpriteNode) {
        self.type = type
        self.node = node
    }
    
}
