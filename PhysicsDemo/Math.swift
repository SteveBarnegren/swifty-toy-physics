//
//  Math.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 27/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class Math {
    
    static func distanceFromPointToLine(point p: Vector2D, start l1: Vector2D, end l2: Vector2D) -> Double {
        
        let a = p.x - l1.x
        let b = p.y - l1.y
        let c = l2.x - l1.x
        let d = l2.y - l1.y
        
        let dot = a * c + b * d
        let lenSq = c * c + d * d
        let param = dot / lenSq
        
        let xx: Double
        let yy: Double
        
        if param < 0 || (l1.x == l2.x && l1.y == l2.y) {
            xx = l1.x
            yy = l1.y 
        } else if param > 1 {
            xx = l2.x
            yy = l2.y
        } else {
            xx = l1.x + param * c
            yy = l1.y + param * d
        }
        
        let dx = p.x - xx
        let dy = p.y - yy
        
        return sqrt(dx * dx + dy * dy)
    }
}
