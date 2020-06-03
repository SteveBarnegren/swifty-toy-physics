//
//  InputHanderAddStaticCircles.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 03/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class InputHandlerAddStaticCircles: InputHandler {
    
    override var instruction: String? {
        return "Click to add circles"
    }
    
    private var radius = 15.0
    private var circlePosition: Vector2D?

    // MARK: - Mouse
    
    override func mouseDown(at position: Vector2D, context: InputHandlerContext) {
        circlePosition = position
    }
    
    override func mouseDragged(to position: Vector2D, context: InputHandlerContext) {
        
        if circlePosition != nil {
            circlePosition = position
        }
        
    }
    
    override func mouseUp(at position: Vector2D, context: InputHandlerContext) {
        
        circlePosition = nil
       
        //let line = PhysicsLine(start: state.start, end: state.end)
        //context.simulation.add(line: line)
        
        //self.state = nil
    }
    
    // MARK: - Keyboard
    
    override func keyDown(key: KeyboardKey) {
        
        switch key {
        case .esc:
            escapePressed()
        default:
            break
        }
    }
    
    private func escapePressed() {
        if circlePosition == nil {
            self.delegate?.inputHandlerDidFinish(handler: self)
        } else {
            circlePosition = nil
        }
    }
    
    // MARK: - Render
    
    override func objectsToRender(context: InputHandlerContext) -> [DrawableObject] {
        
        guard let position = circlePosition else {
            return []
        }
        
        let circle = CircleObject(position: position.nsPoint,
                                  radius: radius,
                                  color: .orange,
                                  drawStyle: .stroke)
        return [.circle(circle)]
    }
}
