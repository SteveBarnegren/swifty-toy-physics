//
//  PolylineInsertPointEditZone.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 05/07/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

private let insertDistance = 1.0

class PolylineInsertPointEditZone: EditZone {

    private let p1: Vector2D
    private let p2: Vector2D
    private let p1Index: Int
    private let p2Index: Int
    private let polyline: PhysicsPolyline
    
    init(p1: Vector2D, p2: Vector2D, p1Index: Int, p2Index: Int, polyline: PhysicsPolyline) {
        self.p1 = p1
        self.p2 = p2
        self.p1Index = p1Index
        self.p2Index = p2Index
        self.polyline = polyline
    }
    
    func attemptToActivate(at location: Vector2D) -> Bool {
        
        guard VectorMath.distanceFromPointToLineSegment(point: location, start: p1, end: p2) < insertDistance else {
            return false
        }
        
        polyline.points.insert(location, at: p2Index)
        return true
    }
    
    func update(location: Vector2D) {
        polyline.points[p2Index] = location
    }
}

extension PolylineInsertPointEditZone {
    
    static func makeZones(for simulation: PhysicsSimulation) -> [PolylineInsertPointEditZone] {
     
        var editZones = [PolylineInsertPointEditZone]()
        
        for polyline in simulation.polyLines {
            for (p1Index, (point, nextPoint)) in zip(polyline.points, polyline.points.dropFirst()).enumerated() {
                editZones.append(
                    PolylineInsertPointEditZone(p1: point,
                                                p2: nextPoint,
                                                p1Index: p1Index,
                                                p2Index: p1Index + 1,
                                                polyline: polyline)
                )
                
            }
        }
        
        return editZones
    }
}
