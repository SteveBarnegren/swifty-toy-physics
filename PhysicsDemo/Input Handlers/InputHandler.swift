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
    
    private struct MouseEvent {
        let position: InputPosition
        let context: InputHandlerContext
    }
    
    private var disableGrid = false
    
    private var lastLeftMouseEvent: MouseEvent?
    
    weak var delegate: InputHandlerDelegate?
    
    var instruction: String? { return nil }
    var uiVariables: [UIVariable] { [] }
    
    // Mouse methods for base class to process
    func processMouseDown(at position: InputPosition, context: InputHandlerContext) {
        mouseDown(at: processedInputPosition(position), context: context)
        lastLeftMouseEvent = MouseEvent(position: position, context: context)
    }
    func processMouseDragged(to position: InputPosition, context: InputHandlerContext) {
        mouseDragged(to: processedInputPosition(position), context: context)
        lastLeftMouseEvent = MouseEvent(position: position, context: context)
    }
    func processMouseUp(at position: InputPosition, context: InputHandlerContext) {
        mouseUp(at: processedInputPosition(position), context: context)
        lastLeftMouseEvent = nil
    }
    
    func processMouseMoved(to position: InputPosition, context: InputHandlerContext) {
        mouseMoved(to: processedInputPosition(position), context: context)
    }

    // Mouse methods for subclasses to override
    func mouseDown(at position: InputPosition, context: InputHandlerContext) {}
    func mouseDragged(to position: InputPosition, context: InputHandlerContext) {}
    func mouseUp(at position: InputPosition, context: InputHandlerContext) {}
    func rightMouseDown(at position: Vector2D, context: InputHandlerContext) {}
    func rightMouseDragged(to position: Vector2D, context: InputHandlerContext) {}
    func rightMouseUp(at position: Vector2D, context: InputHandlerContext) {}
    func mouseMoved(to position: InputPosition, context: InputHandlerContext) {}
    
    func keyDown(key: KeyboardKey, simulation: PhysicsSimulation) {}
    func modifierKeysChanged(keys: [ModifierKey]) {
        
        if keys.contains(.control) {
            setGridDisabled(gridDisabled: true)
        } else {
            setGridDisabled(gridDisabled: false)
        }
    }
    
    func objectsToRender(context: InputHandlerContext) -> [DrawCommand] { [] }
    
    // MARK: - Grid defeat
    
    private func setGridDisabled(gridDisabled: Bool) {
        if gridDisabled == self.disableGrid { return }
        
        self.disableGrid = gridDisabled
        if let mouseEvent = lastLeftMouseEvent {
            processMouseDragged(to: mouseEvent.position, context: mouseEvent.context)
        }
    }
    
    // MARK: - Helpers
    
    private func processedInputPosition(_ position: InputPosition) -> InputPosition {
        if disableGrid {
            return InputPosition(position: position.position, gridPosition: position.position)
        } else {
            return position
        }
    }
}
