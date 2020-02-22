//
//  NSPoint+Extensions.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

extension NSPoint {
    
    var vector2D: Vector2D {
        return Vector2D(Double(x), Double(y))
    }
}
