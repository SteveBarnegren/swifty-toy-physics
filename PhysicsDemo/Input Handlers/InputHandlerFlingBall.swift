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
    
    override func mouseDown(at position: Vector2D, context: InputHandlerContext) {
        
        let ball = Ball(radius: ballRadius)
        ball.position = position
        ball.affectedByPhysics = false
        context.simulation.add(ball: ball)
        
        fling = Fling(ball: ball, flingPos: position)
    }
    
    override func mouseDragged(to position: Vector2D, context: InputHandlerContext) {
        fling?.ball.position = position
    }
    
    override func mouseUp(at position: Vector2D, context: InputHandlerContext) {
        
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
    
    override func objectsToRender(context: InputHandlerContext) -> [DrawCommand] {
        
        guard let fling = fling else {
            return []
        }
        
        var line = LineDrawCommand(from: NSPoint(x: fling.ball.position.x, y: fling.ball.position.y),
                              to: NSPoint(x: fling.flingPos.x, y: fling.flingPos.y))
        line.color = .lightGray
        return [.line(line)]
    }
}
