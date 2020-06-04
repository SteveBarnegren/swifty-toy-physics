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
    let position: Vector2D
    let radius: Double
    let elasticity: Double
    
    init(position: Vector2D, radius: Double, elasticity: Double = 0.7) {
        self.position = position
        self.radius = radius
        self.elasticity = elasticity
    }
}
