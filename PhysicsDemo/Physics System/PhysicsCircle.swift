//
//  PhysicsCircle.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 04/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

class PhysicsCircle {
    var position: Vector2D
    var radius: Double
    var elasticity: Double
    
    init(position: Vector2D, radius: Double, elasticity: Double = 1.0) {
        self.position = position
        self.radius = radius
        self.elasticity = elasticity
    }
}
