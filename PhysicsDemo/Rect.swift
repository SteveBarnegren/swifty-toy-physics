//
//  Rect.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 06/07/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

class Rect: Codable {
    static let zero = Rect(origin: .zero, size: .zero)
    
    var origin: Vector2D
    var size: Vector2D
    
    var minX: Double { return origin.x }
    var minY: Double { return origin.y }
    var maxX: Double { return origin.x + size.width }
    var maxY: Double { return origin.y + size.height }
    
    init(x: Double, y: Double, w: Double, h: Double) {
        self.origin = Vector2D(x, y)
        self.size = Vector2D(w, h)
    }
    
    init(origin: Vector2D, size: Vector2D) {
        self.origin = origin
        self.size = size
    }
    
    func intersects(_ other: Rect) -> Bool {
        
        // Is other above us?
        if other.minY > self.maxY { return false }
        
        // Is other to the right of us?
        if other.minX > self.maxX { return false }
        
        // Is other to the left of us?
        if other.maxX < self.minX { return false }
        
        // Is other below us?
        if other.maxY < self.minY { return false }
        
        return true
    }
}
