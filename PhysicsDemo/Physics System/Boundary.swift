//
//  Boundary.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class Boundary {
    
    enum Orientation {
        case minX
        case maxX
        case minY
        case maxY
    }
    
    let orientation: Orientation
    var value: Double = 0
    var elasticity = 0.7
    
    init(orientation: Orientation) {
        self.orientation = orientation
    }
}

