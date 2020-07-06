//
//  PhysicsPolyline.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 01/07/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

class PhysicsPolyline: Codable {
    
    var points: [Vector2D] {
        didSet {
            _boundingBox = nil
        }
    }
    
    init(points: [Vector2D]) {
        self.points = points
    }
    
    private var _boundingBox: Rect? = nil
    
    var boundingBox: Rect {
        
        func calculateBoundingBox() -> Rect {
            if points.isEmpty { return .zero }
            
            var minX = 0.0
            var maxX = 0.0
            var minY = 0.0
            var maxY = 0.0
            
            for p in points {
                minX = min(minX, p.x)
                maxX = max(maxX, p.x)
                minY = min(minY, p.y)
                maxY = max(maxY, p.y)
            }
            
            return Rect(x: minX, y: minY, w: maxX - minX, h: maxY - minY)
        }
        
        if let bb = _boundingBox {
            return bb
        }
        
        let bb = calculateBoundingBox()
        self._boundingBox = bb
        return bb
    }
}
