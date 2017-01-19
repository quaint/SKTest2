//
//  Keyboard.swift
//
//  Created by Bojan Percevic on 5/21/15.
//  Copyright (c) 2015 Bojan Percevic. All rights reserved.
//

import AppKit

enum Key: CUnsignedShort {
    case a = 0x00 // = 0
    case s = 0x01
    case d = 0x02
    case f = 0x03
    case h = 0x04
    case g = 0x05
    case z = 0x06
    case x = 0x07
    case c = 0x08
    case v = 0x09
    case b = 0x0B
    case q = 0x0C
    case w = 0x0D
    case e = 0x0E
    case r = 0x0F
    case y = 0x10
    case t = 0x11
    case one = 0x12
    case two = 0x13
    case three = 0x14
    case four = 0x15
    case six = 0x16
    case five = 0x17
    case equals = 0x18
    case nine = 0x19
    case seven = 0x1A
    case minus = 0x1B
    case eight = 0x1C
    case zero = 0x1D
    case rightBracket = 0x1E
    case o = 0x1F
    case u = 0x20
    case leftBracket = 0x21
    case i = 0x22
    case p = 0x23
    case `return` = 0x24
    case l = 0x25
    case j = 0x26
    case quote = 0x27
    case k = 0x28
    case semicolon = 0x29
    case backslash = 0x2A
    case comma = 0x2B
    case slash = 0x2C
    case n = 0x2D
    case m = 0x2E
    case period = 0x2F
    case tab = 0x30
    case space = 0x31
    case grave = 0x32
    case delete = 0x33
    
    case escape = 0x35
    
    case command = 0x37
    case leftShift = 0x38
    case capsLock = 0x39
    case leftOption = 0x3A
    case leftControl = 0x3B
    case rightShift = 0x3C
    case rightOption = 0x3D
    case rightControl = 0x3E
    case function = 0x3F
    case f17 = 0x40
    case keypadDecimal = 0x41
    
    case keypadMultiply = 0x43
    
    case keypadPlus = 0x45
    
    case keypadClear = 0x47
    case volumeUp = 0x48
    case volumeDown = 0x49
    case mute = 0x4A
    case keypadDivide = 0x4B
    case keypadEnter = 0x4C
    
    case keypadMinus = 0x4E
    case f18 = 0x4F
    case f19 = 0x50
    case keypadEquals = 0x51
    case keypadZero = 0x52
    case keypadOne = 0x53
    case keypadTwo = 0x54
    case keypadThree = 0x55
    case keypadFour = 0x56
    case keypadFive = 0x57
    case keypadSix = 0x58
    case keypadSeven = 0x59
    case f20 = 0x5A
    case keypadEight = 0x5B
    case keypadNine = 0x5C
    
    case f5 = 0x60
    case f6 = 0x61
    case f7 = 0x62
    case f3 = 0x63
    case f8 = 0x64
    case f9 = 0x65
    case f11 = 0x67
    case f13 = 0x69
    case f16 = 0x6A
    case f14 = 0x6B
    case f10 = 0x6D
    case f12 = 0x6F
    case f15 = 0x71
    case help = 0x72
    case home = 0x73
    case pageUp = 0x74
    case forwardDelete = 0x75
    case f4 = 0x76
    case end = 0x77
    case f2 = 0x78
    case pageDown = 0x79
    case f1 = 0x7A
    case left = 0x7B
    case right = 0x7C
    case down = 0x7D
    case up = 0x7E // = 126
    
    case count = 0x7F
}

struct KeyState {
    var keys = [Bool](repeating: false, count: Int(Key.count.rawValue))
}

class Keyboard {
    
    static let sharedKeyboard = Keyboard()
    
    var prev: KeyState
    var curr: KeyState
    
    init() {
        prev = KeyState()
        curr = KeyState()
    }
    
    func handleKey(_ event: NSEvent, isDown: Bool) {
        if (isDown) {
            curr.keys[Int(event.keyCode)] = true
        } else {
            curr.keys[Int(event.keyCode)] = false
        }
    }
    
    func justPressed(_ keys: Key...) -> Bool {
        for key in keys {
            if (curr.keys[Int(key.rawValue)] == true && prev.keys[Int(key.rawValue)] == false) {
                return true
            }
        }
        return false
    }
    
    func justReleased(_ keys: Key...) -> Bool {
        for key in keys {
            if (prev.keys[Int(key.rawValue)] == true && curr.keys[Int(key.rawValue)] == false) {
                return true
            }
        }
        return false
    }
    
    func pressed(_ keys: Key...) -> Bool {
        for key in keys {
            if (prev.keys[Int(key.rawValue)] == true && curr.keys[Int(key.rawValue)] == true) {
                return true
            }
        }
        return false
    }
    
    func update() {
        prev = curr
    }
    
}
