//
//  InputHandlerFlingBall.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

private let flingStrength = 10.0

private struct Fling {
    var ball: Ball
    var flingPos: Vector2D
}

class InputHandlerFlingBall: InputHandler {

    private var fling: Fling?
    
    func mouseDown(at position: Vector2D, context: InputHandlerContext) {
        
        let ball = Ball(radius: ballRadius)
        ball.affectedByPhysics = false
        context.world.add(ball: ball)
        
        fling = Fling(ball: ball, flingPos: position)
    }
    
    func mouseDragged(to position: Vector2D, context: InputHandlerContext) {
        fling?.ball.position = position
    }
    
    func mouseUp(at position: Vector2D, context: InputHandlerContext) {
        
        guard let fling = self.fling else {
            return
        }
        
        let xOffset = fling.flingPos.x - fling.ball.position.x
        let yOffset = fling.flingPos.y - fling.ball.position.y
        
        fling.ball.velocity.x += xOffset * flingStrength
        fling.ball.velocity.y += yOffset * flingStrength
        fling.ball.affectedByPhysics = true

        self.fling = nil
    }
}
