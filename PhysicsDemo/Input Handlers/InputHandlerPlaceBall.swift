//
//  InputHandlerPlaceBall.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class InputHandlerPlaceBall: InputHandler {
    
    private var ball: Ball?
    
    override func mouseDown(at position: Vector2D, context: InputHandlerContext) {
                
        let ball = Ball(radius: 5)
        ball.position = constrainLocation(position)
        ball.affectedByPhysics = false
        context.simulation.add(ball: ball)
        
        self.ball = ball
    }
    
    override func mouseDragged(to position: Vector2D, context: InputHandlerContext) {
        ball?.position = constrainLocation(position)
    }
    
    override func mouseUp(at position: Vector2D, context: InputHandlerContext) {
        ball?.position = constrainLocation(position)
        ball?.affectedByPhysics = true
        ball = nil
    }
    
    private func constrainLocation(_ p: Vector2D) -> Vector2D {
        var p = p
        p.x = p.x.constrained(min: ballRadius, max: simulationSize.width-ballRadius)
        p.y = p.y.constrained(min: ballRadius, max: simulationSize.height-ballRadius)
        return p
    }
}
