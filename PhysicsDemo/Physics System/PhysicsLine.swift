//
//  PhysicsLine.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 23/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class PhysicsLine: Codable {
    var start: Vector2D
    var end: Vector2D
    var elasticity = 1.0
    
    var boundingBox: Rect {
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxX = max(start.x, end.x)
        let maxY = max(start.y, end.y)
        
        return Rect(x: minX,
                    y: minY,
                    w: maxX - minX,
                    h: maxY - minY)
    }
    
    init(start: Vector2D, end: Vector2D) {
        self.start = start
        self.end = end
    }
}
