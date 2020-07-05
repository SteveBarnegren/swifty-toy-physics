//
//  PhysicsSimulation.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

class PhysicsSimulation: Codable {
    
    var boundaries = [Boundary]()
    
    var balls = [Ball]()
    var lines = [PhysicsLine]()
    var circles = [PhysicsCircle]()
    var polyLines = [PhysicsPolyline]()
    var gravity = Double.zero
    var enableBallCollisions = true
    
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
    
    func remove(circle: PhysicsCircle) {
        circles.removeAll(where: { $0 === circle })
    }
    
    func removeAllCircles() {
        circles.removeAll()
    }
    
    // MARK: - Manage Polylines
    
    func add(polyline: PhysicsPolyline) {
        polyLines.append(polyline)
    }
    
    func remove(polyline: PhysicsPolyline) {
        polyLines.removeAll(where: { $0 === polyline })
    }
    
    func removeAllPolylines() {
        polyLines.removeAll()
    }
    
    // MARK: - Clear all
    
    func clearAll() {
        removeAllBalls()
        removeAllLines()
        removeAllCircles()
        removeAllPolylines()
    }
    
    // MARK: - Step
    
    func step(dt: Double) {
        
        for (ball, otherBalls) in balls.eachWithRemaining() where ball.affectedByPhysics {
            // Add gravity
            ball.velocity.y += gravity * dt
            
            // Move ball
            ball.position += ball.velocity * dt
            
            // Resolve boundary collisions
            boundaries.forEach { resolveCollision(ball: ball, boundary: $0) }
            
            // Resolve line collisions
            if let prevPos = ball.previousPosition {
                lines.forEach { resolveCollision(ball: ball, previousBallPos: prevPos, line: $0) }
            }
            
            // Resolve circle collisions
            if let prevPos = ball.previousPosition {
                circles.forEach { resolveCollision(ball: ball, previousBallPos: prevPos, physicsCircle: $0) }
            }
            
            // Resolve polyline collisions
            if let prevPos = ball.previousPosition {
                polyLines.forEach { resolveCollision(ball: ball, previousBallPos: prevPos, polyline: $0) }
            }
            
            // Resolve ball collisions
            if enableBallCollisions {
                for otherBall in otherBalls {
                    resolveCollision(ball1: ball, ball2: otherBall)
                }
            }
            
            ball.previousPosition = ball.position
        }
    }
    
    // MARK: - Ball Collisions
        
    private func resolveCollision(ball1: Ball, ball2: Ball) {
                
        let distance = ball1.position.distance(to: ball2.position)
        if distance > ball1.radius + ball2.radius {
            return
        }
        
        // Get the normal and tangent vectors
        let normal = (ball2.position - ball1.position).normalized()
        let tangent = self.normals(for: normal).second
        
        // Move the balls apart so that they no longer overlap
        let contactPoint = ball1.position + (ball2.position - ball1.position) * (ball1.radius / distance)
        ball1.position = contactPoint - normal.with(magnitude: ball1.radius)
        ball2.position = contactPoint + normal.with(magnitude: ball2.radius)
        
        let ball1TangentDp = tangent.dotProduct(with: ball1.velocity)
        let ball2TangentDp = tangent.dotProduct(with: ball2.velocity)
        
        let ball1NormalDp = normal.dotProduct(with: ball1.velocity)
        let ball2NormalDp = normal.dotProduct(with: ball2.velocity)
        
        // Conservation of momentum
        let m1 = (ball1NormalDp * (ball1.mass - ball2.mass) + 2.0 * ball2.mass * ball2NormalDp) / (ball1.mass + ball2.mass)
        let m2 = (ball2NormalDp * (ball2.mass - ball1.mass) + 2.0 * ball1.mass * ball1NormalDp) / (ball1.mass + ball2.mass)

        ball1.velocity = tangent * ball1TangentDp + normal * m1
        ball2.velocity = tangent * ball2TangentDp + normal * m2
    }
    
    // MARK: - Boundary Collisions
    
    private func resolveCollision(ball: Ball, boundary: Boundary) {
        
        if boundary.isEnabled == false { return }
        
        switch boundary.orientation {
        case .minX:
            if ball.minX < boundary.value {
                ball.position.x = boundary.value + ball.radius
                ball.velocity.x = abs(ball.velocity.x) * boundary.elasticity * ball.elasticity
            }
        case .maxX:
            if ball.maxX > boundary.value {
                ball.position.x = boundary.value - ball.radius
                ball.velocity.x = -abs(ball.velocity.x) * boundary.elasticity * ball.elasticity
            }
        case .minY:
            if ball.minY < boundary.value {
                ball.position.y = boundary.value + ball.radius
                ball.velocity.y = abs(ball.velocity.y) * boundary.elasticity * ball.elasticity
            }
        case .maxY:
            if ball.maxY > boundary.value {
                ball.position.y = boundary.value - ball.radius
                ball.velocity.y = -abs(ball.velocity.y) * boundary.elasticity * ball.elasticity
            }
        }
    }
    
    // MARK: - Line Collisions
    
    private func resolveCollision(ball: Ball, previousBallPos: Vector2D, line: PhysicsLine) {
        
        if ball.position == previousBallPos {
            return
        }
        
        let ballLine = LineSegment(start: previousBallPos, end: ball.position)
        let collidingLine = LineSegment(start: line.start, end: line.end)
        updateBallPositionAndVelocity(line: collidingLine,
                                      ballLine: ballLine,
                                      ball: ball,
                                      elasticity: ball.elasticity)
        
        for lineEnd in [line.start, line.end] {
            let circle = Circle(center: lineEnd, radius: ball.radius)
            resolveCollision(ball: ball,
                             previousBallPos: previousBallPos,
                             circle: circle,
                             elasticity: ball.elasticity)
        }
    }
    
    func updateBallPositionAndVelocity(line: LineSegment, ballLine: LineSegment, ball: Ball, elasticity: Double) {
        
        var line = line
        
        // Work out the normal to reflect against
        let reflectionNormal = self.reflectingNormal(forLine: line, ballLine: ballLine)
        
        // Shift the line so that it extends to the ball radius
        let lineAdjustment = reflectionNormal.with(magnitude: ball.radius)
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
    
    // MARK: - Circle collisions
    
    private func resolveCollision(ball: Ball, previousBallPos: Vector2D, physicsCircle: PhysicsCircle) {
        let circle = Circle(center: physicsCircle.position, radius: physicsCircle.radius + ball.radius)
        resolveCollision(ball: ball, previousBallPos: previousBallPos, circle: circle, elasticity: ball.elasticity)
    }
    
    private func resolveCollision(ball: Ball, previousBallPos: Vector2D, circle: Circle, elasticity: Double) {
        
        let lineSegment = LineSegment(start: previousBallPos, end: ball.position)
        
        guard let intersection = calculateIntersection(circle: circle, lineSegment: lineSegment) else {
            return
        }
        
        let reflectionNormal = (intersection - circle.center).normalized()
        
        // Use dot product to project against the reflection vector and subtract twice to get the 'mirror'
        let ballDirection = (ball.position - previousBallPos).normalized()
        var bounce = ballDirection - (2.0 * reflectionNormal * ballDirection.dotProduct(with: reflectionNormal))
        
        // Scale to the distance the the ball extends past the line
        let extendDistance = intersection.distance(to: ball.position)
        bounce = bounce.normalized() * extendDistance
        
        ball.position = intersection + bounce
        ball.velocity = bounce.with(magnitude: ball.velocity.magnitude) * elasticity
    }
    
    private func calculateIntersection(circle: Circle, lineSegment: LineSegment) -> Vector2D? {
        
        // Check if the line segment is outside of the range of the circle
        if !circle.xRange.overlaps(lineSegment.xRange) || !circle.yRange.overlaps(lineSegment.yRange) {
            return nil
        }
        
        // Calculate the line vector and a vector to the circle center
        let lineVector = lineSegment.end - lineSegment.start
        let toCircleVector = circle.center - lineSegment.start
        
        // Find the center of the cord that the line cuts through the circle
        let cordCenter = lineSegment.start + toCircleVector.project(onTo: lineVector)
        
        // No intersection if greater than radius
        let distanceToCenter = cordCenter.distance(to: circle.center)
        if distanceToCenter > circle.radius {
            return nil
        }
        
        // Find the normals along the chord
        let centerToChord = cordCenter - circle.center
        let normals = self.normals(for: centerToChord)
        
        // Trace along the normal the correct amount using Pythagoras
        let normal = normals.first.dotProduct(with: lineVector) < 0 ? normals.first : normals.second
        let offset = sqrt((circle.radius * circle.radius) - (distanceToCenter * distanceToCenter))
        let intersection = cordCenter + normal.with(magnitude: offset)
        
        // Check the intersection is in the bounds of the line segment
        if intersection.x < min(lineSegment.start.x, lineSegment.end.x) { return nil }
        if intersection.x > max(lineSegment.start.x, lineSegment.end.x) { return nil }
        if intersection.y < min(lineSegment.start.y, lineSegment.end.y) { return nil }
        if intersection.y > max(lineSegment.start.y, lineSegment.end.y) { return nil }
        
        return intersection
    }
    
    // MARK: - Polyline Collisions
    
    private func resolveCollision(ball: Ball, previousBallPos: Vector2D, polyline: PhysicsPolyline) {
        
        for (point, nextPoint) in zip(polyline.points, polyline.points.dropFirst()) {
            let line = PhysicsLine(start: point, end: nextPoint)
            resolveCollision(ball: ball, previousBallPos: previousBallPos, line: line)
        }
    }
    
    // MARK: - Helpers
    
    private func normals(for vector: Vector2D) -> (first: Vector2D, second: Vector2D) {
         return (Vector2D(x: -vector.y, y: vector.x), Vector2D(x: vector.y, y: -vector.x))
     }
}
