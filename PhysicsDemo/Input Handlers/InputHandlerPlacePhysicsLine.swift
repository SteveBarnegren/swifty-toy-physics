//
//  InputHandlerPlacePhysicsLine.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 23/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

private struct State {
    var start: Vector2D
    var end: Vector2D
}

class InputHandlerPlacePhysicsLine: InputHandler {
    
    private var state: State?
    
    override var instruction: String? {
        return "Drag to create a line"
    }
    
    // MARK: - Mouse handling
    
    override func mouseDown(at position: Vector2D, context: InputHandlerContext) {
        self.state = State(start: position, end: position)
    }
    
    override func mouseDragged(to position: Vector2D, context: InputHandlerContext) {
        self.state?.end = position
    }
    
    override func mouseUp(at position: Vector2D, context: InputHandlerContext) {
        guard let state = self.state else {
            return
        }
        
        let line = PhysicsLine(start: state.start, end: state.end)
        context.simulation.add(line: line)
        
        self.state = nil
    }
    
    // MARK: - Key handling
    
    override func keyDown(key: KeyboardKey) {
        
        switch key {
        case .esc:
            escapeButtonPressed()
        default:
            break
        }
    }
    
    private func escapeButtonPressed() {
        if state != nil {
            state = nil
        } else {
            print("Place line input handler finished")
            delegate?.inputHandlerDidFinish(handler: self)
        }
    }
    
    override func objectsToRender() -> [DrawableObject] {
        
        guard let state = self.state else {
            return []
        }
        
        let start = NSPoint(x: state.start.x, y: state.start.y)
        let end = NSPoint(x: state.end.x, y: state.end.y)
        
        let line = LineObject(from: start,
                              to: end,
                              color: .white,
                              strokeWidth: 1)
        return [.line(line)]
    }
}
