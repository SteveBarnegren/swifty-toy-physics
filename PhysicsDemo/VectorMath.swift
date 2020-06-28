//
//  VectorMath.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 31/05/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

struct Line {
    let constant: Double
    let multiplier: Double
    
    var hasInfiniteSlope: Bool {
        return multiplier == .infinity || multiplier == -.infinity
    }
    
    func y(forX x: Double) -> Double {
        return multiplier*x + constant
    }
    
    
}

struct LineSegment {
    var start: Vector2D
    var end: Vector2D
    
    var xRange: ClosedRange<Double> {
        (min(start.x, end.x))...(max(start.x, end.x))
    }
    
    var yRange: ClosedRange<Double> {
        (min(start.y, end.y))...(max(start.y, end.y))
    }
}

struct Circle {
    let center: Vector2D
    let radius: Double
    
    var xRange: ClosedRange<Double> {
        (center.x - radius)...(center.x + radius)
    }
    
    var yRange: ClosedRange<Double> {
        (center.y - radius)...(center.y + radius)
    }
}

class VectorMath {
    
    static func distanceFromPointToLineSegment(point p: Vector2D, start l1: Vector2D, end l2: Vector2D) -> Double {
        let line = lineFromSegment(p1: l1, p2: l2)
        
        // Work out the perpendicular line
        let yDiff = l2.y - l1.y
        let xDiff = l2.x - l1.x
        let normalSlope = xDiff / -yDiff
        let yIntercept = p.y - p.x*normalSlope
        let perpendicularLine = Line(constant: yIntercept, multiplier: normalSlope)
        
        // Check the distance to the intersection
        guard let intersection = self.intersectionOfLines(l1: line, l2: perpendicularLine) else {
            fatalError("Perpendicular lines should intersect")
        }
        
        let segment = LineSegment(start: l1, end: l2)
        if segment.xRange.contains(intersection.x) && segment.yRange.contains(intersection.y) {
            return intersection.distance(to: p)
        }
        
        // If outside the segment, check the distance to the ends
        return sqrt(min(l1.distanceSquared(to: p), l2.distanceSquared(to: p)))
    }

    
    static func intersectionOfLineSegments(start1: Vector2D,
                                           end1: Vector2D,
                                           start2: Vector2D,
                                           end2: Vector2D) -> Vector2D? {
                
        let l1 = lineFromSegment(p1: start1, p2: end1)
        let l2 = lineFromSegment(p1: start2, p2: end2)
        
        let intersection: Vector2D
        
        if l1.hasInfiniteSlope && l2.hasInfiniteSlope {
            return nil
        }
        if l1.hasInfiniteSlope {
            intersection = Vector2D(start1.x, l2.y(forX: start1.x))
        } else if l2.hasInfiniteSlope {
            intersection = Vector2D(x: start2.x, y: l1.y(forX: start2.x))
        } else {
            guard let i = intersectionOfLines(l1: l1, l2: l2) else {
                return nil
            }
            intersection = i
        }
        
        func isInsideLineSegment(_ segStart: Vector2D, _ segEnd: Vector2D) -> Bool {
            if intersection.x < min(segStart.x, segEnd.x) { return false }
            if intersection.x > max(segStart.x, segEnd.x) { return false }
            if intersection.y < min(segStart.y, segEnd.y) { return false }
            if intersection.y > max(segStart.y, segEnd.y) { return false }
            return true
        }
        
        if isInsideLineSegment(start1, end1) && isInsideLineSegment(start2, end2) {
            return intersection
        } else {
            return nil
        }
    }
    
    static func intersectionOfLines(l1: Line, l2: Line) -> Vector2D? {
        
        // If the slopes are the same then they don't intercept
        if l1.multiplier == l2.multiplier {
            return nil
        }
        
        // Find the x point of intersection
        let m = l1.multiplier - l2.multiplier
        let c = l2.constant - l1.constant
        let x = c / m
        
        // Determine y for x
        let y = l1.y(forX: x)
        
        return Vector2D(x, y)
    }
    
    static func lineFromSegment(p1: Vector2D, p2: Vector2D) -> Line {
        let slope = p1.slope(to: p2)
        
        let yIntercept = p1.y - (p1.x*slope)
        return Line(constant: yIntercept, multiplier: slope)
    }
}


