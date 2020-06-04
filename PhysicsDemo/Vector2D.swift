//
//  Vector2D.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

typealias Vector2D = Vector2<Double>
// MARK: - Conversions

extension Vector2D {
    
    init(_ nsPoint: NSPoint) {
        self.init(Double(nsPoint.x), Double(nsPoint.y))
    }
    
    var cgSize: CGSize {
        CGSize(width: self.width, height: self.height)
    }
    
    var nsPoint: NSPoint {
        NSPoint(x: self.x, y: self.y)
    }
}
