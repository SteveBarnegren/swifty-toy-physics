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

protocol InputHandlerDelegate: class {
    func inputHandlerDidFinish(handler: InputHandler)
}

struct InputPosition {
    let position: Vector2D
    let gridPosition: Vector2D
}

class InputHandler {
    
    weak var delegate: InputHandlerDelegate?
    
    var instruction: String? { return nil }
    var uiVariables: [UIVariable] { [] }
    
    func mouseDown(at position: InputPosition, context: InputHandlerContext) {}
    func mouseDragged(to position: InputPosition, context: InputHandlerContext) {}
    func mouseUp(at position: InputPosition, context: InputHandlerContext) {}
    func rightMouseDown(at position: Vector2D, context: InputHandlerContext) {}
    func rightMouseDragged(to position: Vector2D, context: InputHandlerContext) {}
    func rightMouseUp(at position: Vector2D, context: InputHandlerContext) {}
    
    func keyDown(key: KeyboardKey) {}
    
    func objectsToRender(context: InputHandlerContext) -> [DrawCommand] { [] }
}
