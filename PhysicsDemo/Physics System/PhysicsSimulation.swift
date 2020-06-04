//
//  PhysicsSimulation.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

class PhysicsSimulation {
    
    var boundaries = [Boundary]()
    
    var balls = [Ball]()
    var lines = [PhysicsLine]()
    var circles = [PhysicsCircle]()
    var gravity = Double.zero
    
    func add(boundary: Boundary) {
        self.boundaries.append(boundary)
    }
    
    // MARK: - Manage Balls
    
    func add(ball: Ball) {
        self.balls.append(ball)
    }
    
    func removeAllBalls() {
        self.balls.removeAll()
    }
    
    // MARK: - Manage Lines
    
    func add(line: PhysicsLine) {
        self.lines.append(line)
    }
    
    func removeAllLines() {
        self.lines.removeAll()
    }
    
    // MARK: - Manage Circles
    
    func add(circle: PhysicsCircle) {
        circles.append(circle)
    }
    
    // MARK: - Step
    
    func step(dt: Double) {
        
        for ball in balls where ball.affectedByPhysics {
            // Add gravity
            ball.velocity.y += gravity
            
            // Move ball
            ball.position += ball.velocity * dt
            
            // Resolve boundary collisions
            boundaries.forEach { resolveCollision(ball: ball, boundary: $0) }
            
            // Resolve line collisions
            if let previousBallPosition = ball.previousPosition {
                lines.forEach { resolveCollision(ball: ball, previousBallPos: previousBallPosition, line: $0) }
            }
            
            ball.previousPosition = ball.position
        }
    }
    
    private func resolveCollision(ball: Ball, boundary: Boundary) {
        
        switch boundary.orientation {
        case .minX:
            fatalError()
        case .maxX:
            if ball.maxX > boundary.value {
                ball.position.x = boundary.value - ball.radius
                ball.velocity.x = -abs(ball.velocity.x) * boundary.elasticity
            }
        case .minY:
            if ball.minY < boundary.value {
                ball.position.y = boundary.value + ball.radius
                ball.velocity.y = abs(ball.velocity.y) * boundary.elasticity
            }
        case .maxY:
            fatalError()
        }
    }
    
    private func resolveCollision(ball: Ball, previousBallPos: Vector2D, line: PhysicsLine) {
        
        if ball.position == previousBallPos {
            return
        }
        
        let ballLine = LineSegment(start: previousBallPos, end: ball.position)
        let collidingLine = LineSegment(start: line.start, end: line.end)
        updateBallPositionAndVelocity(line: collidingLine, ballLine: ballLine, ball: ball, elasticity: line.elasticity)
    }
    
    func updateBallPositionAndVelocity(line: LineSegment, ballLine: LineSegment, ball: Ball, elasticity: Double) {
        
        var line = line
        
        // Work out the normal to reflect against
        let reflectionNormal = self.reflectingNormal(forLine: line, ballLine: ballLine)
        
        // Shift the line so that it extends to the ball radius
        let lineAdjustment = reflectionNormal.with(magnitude: ballRadius)
        line.start += lineAdjustment
        line.end += lineAdjustment
        
        // Work out the point of intersection
        guard let intersection = VectorMath
            .intersectionOfLineSegments(start1: line.start,
                                        end1: line.end,
                                        start2: ballLine.start,
                                        end2: ballLine.end) else {
                                            return
        }
                
        // Use dot product to project against the reflection vector and subtract twice to get the 'mirror'
        let ballDirection = (ballLine.end - ballLine.start).normalized()
        var bounce = ballDirection - (2.0 * reflectionNormal * ballDirection.dotProduct(with: reflectionNormal))

        // Scale to the distance the the ball extends past the line
        let extendDistance = intersection.distance(to: ballLine.end)
        bounce = bounce.normalized() * extendDistance
        
        ball.position = intersection + bounce
        ball.velocity = bounce.with(magnitude: ball.velocity.magnitude) * elasticity
    }
    
    private func reflectingNormal(forLine line: LineSegment, ballLine: LineSegment) -> Vector2D {
        // There's two possible normals for the line. We want the one that goes in the
        // reverse direction to the ball
        
        let lineDirection = (line.end - line.start).normalized()
        let ballDirection = (ballLine.end - ballLine.start).normalized()
        
        let possibleNormal1 = Vector2D(x: -lineDirection.y, y: lineDirection.x)
        let possibleNormal2 = Vector2D(x: lineDirection.y, y: -lineDirection.x)
        
        return ballDirection.dotProduct(with: possibleNormal1) < 0 ? possibleNormal1 : possibleNormal2
    }
}
