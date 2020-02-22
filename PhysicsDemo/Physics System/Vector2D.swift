//
//  Vector2D.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

struct Vector2D: Equatable {
    var x: Double
    var y: Double
    
    var width: Double { x }
    var height: Double { y }
    
    static let zero = Vector2D(0,0)
    
    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    init(_ nsPoint: NSPoint) {
        self.x = Double(nsPoint.x)
        self.y = Double(nsPoint.y)
    }
    
    func distance(to other: Vector2D) -> Double {
        
        let xDiff = other.x - self.x
        let yDiff = other.y - self.y
        return sqrt(xDiff*xDiff + yDiff*yDiff)
    }
}

func + (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    return Vector2D(lhs.x + rhs.x, lhs.y + rhs.y)
}

func * (lhs: Vector2D, rhs: Double) -> Vector2D {
    return Vector2D(lhs.x * rhs, lhs.y * rhs)
}

func / (lhs: Vector2D, rhs: Double) -> Vector2D {
    return Vector2D(lhs.x / rhs, lhs.y / rhs)
}

func +=(lhs: inout Vector2D, rhs: Vector2D) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}

func -=(lhs: inout Vector2D, rhs: Vector2D) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

// MARK: - Conversions

extension Vector2D {
    
    var cgSize: CGSize {
        CGSize(width: self.width, height: self.height)
    }
    
}

