//
//  Ball.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class Ball {
    
    var position = Vector2D.zero
    var velocity = Vector2D.zero
    var radius: Double
    var affectedByPhysics = false
    
    var minY: Double { position.y - radius }
    var maxY: Double { position.y + radius }
    var minX: Double { position.x - radius }
    var maxX: Double { position.x + radius }
    
    init(radius: Double) {
        self.radius = radius
    }
}

