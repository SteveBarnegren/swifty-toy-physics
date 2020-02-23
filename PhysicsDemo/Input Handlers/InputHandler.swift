//
//  InputHandler.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

struct InputHandlerContext {
    let simulation: PhysicsSimulation
    let simulationSize: Vector2D
}

protocol InputHandler {
    
    func mouseDown(at position: Vector2D, context: InputHandlerContext)
    
    func mouseDragged(to position: Vector2D, context: InputHandlerContext)
    
    func mouseUp(at position: Vector2D, context: InputHandlerContext)
    
    func objectsToRender() -> [DrawableObject]
}

extension InputHandler {
    func objectsToRender() -> [DrawableObject] {
        return []
    }
}
