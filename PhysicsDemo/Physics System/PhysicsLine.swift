//
//  PhysicsLine.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 23/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class PhysicsLine {
    var start: Vector2D
    var end: Vector2D
    var elasticity = 0.9
    
    init(start: Vector2D, end: Vector2D) {
        self.start = start
        self.end = end
    }
}