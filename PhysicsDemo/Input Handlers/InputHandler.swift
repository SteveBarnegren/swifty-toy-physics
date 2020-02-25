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

class InputHandler {
    
    weak var delegate: InputHandlerDelegate?
    
    var instruction: String? { return nil }
    
    func mouseDown(at position: Vector2D, context: InputHandlerContext) {}
    func mouseDragged(to position: Vector2D, context: InputHandlerContext) {}
    func mouseUp(at position: Vector2D, context: InputHandlerContext) {}
    
    func keyDown(key: KeyboardKey) {}
    
    func objectsToRender(context: InputHandlerContext) -> [DrawableObject] { [] }
}
