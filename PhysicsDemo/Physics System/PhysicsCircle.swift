//
//  PhysicsCircle.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 04/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

class PhysicsCircle: Codable {
    var position: Vector2D
    var radius: Double
    var elasticity: Double
    
    var boundingBox: Rect {
        return Rect(x: position.x - radius,
                    y: position.y - radius,
                    w: radius*2,
                    h: radius*2)
    }
    
    init(position: Vector2D, radius: Double, elasticity: Double = 1.0) {
        self.position = position
        self.radius = radius
        self.elasticity = elasticity
    }
}
