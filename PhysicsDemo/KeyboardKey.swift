//
//  Key.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 23/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

enum KeyboardKey {
    case esc
    
    init?(keyCode: UInt16) {
        
        switch keyCode {
        case 53: self = .esc
        default:
            return nil
        }
    }
}


