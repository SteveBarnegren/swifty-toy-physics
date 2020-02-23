//
//  PhysicsSimulation.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class PhysicsSimulation {
    
    var boundaries = [Boundary]()
    
    var balls = [Ball]()
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
    
    func step(dt: Double) {
        
        for ball in balls where ball.affectedByPhysics {
            // Add gravity
            ball.velocity.y += gravity
            
            // Move ball
            ball.position += ball.velocity * dt
            
            boundaries.forEach { resolveCollision(ball: ball, boundary: $0) }
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
}
