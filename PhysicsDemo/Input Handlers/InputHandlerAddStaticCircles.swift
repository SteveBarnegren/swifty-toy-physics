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
    private var drawExampleCircle = false

    // MARK: - Mouse
    
    override func mouseDown(at position: Vector2D, context: InputHandlerContext) {
        drawExampleCircle = false
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
        
        if drawExampleCircle {
            drawExampleCircle = false
            return
        } else if circlePosition != nil {
            circlePosition = nil
        } else {
            self.delegate?.inputHandlerDidFinish(handler: self)
        }
    }
    
    // MARK: - Render
    
    override func objectsToRender(context: InputHandlerContext) -> [DrawCommand] {
        return placeCircleDrawCommands() + exampleCircleDrawCommands(forSimulationSize: context.simulationSize)
    }
    
    private func placeCircleDrawCommands() -> [DrawCommand] {
        guard let position = circlePosition else {
            return []
        }
        
        let circle = CircleDrawCommand(position: position,
                                       radius: radius,
                                       color: .orange,
                                       drawStyle: .stroke)
        
        return [.circle(circle)]
    }
    
    private func exampleCircleDrawCommands(forSimulationSize simSize: Vector2D) -> [DrawCommand] {
        
        if drawExampleCircle == false {
            return []
        }
       
        let padding = 4.0
        let rectSize = padding*2 + radius*2
        let backingRect = RectDrawCommand(origin: Vector2D(simSize.width - rectSize, simSize.height - rectSize),
                                          size: Vector2D(rectSize, rectSize),
                                          color: .gray,
                                          drawStyle: .fill)
        
        let circle = CircleDrawCommand(position: Vector2D(simSize.width - padding - radius, simSize.height - padding - radius),
                                       radius: radius,
                                       color: .white,
                                       drawStyle: .stroke)
        
        return [.rect(backingRect), .circle(circle)]
    }
    
    // MARK: - Variables
    
    override var uiVariables: [UIVariable] {
        let radiusVariable = UIVariableDouble(name: "Radius",
                                              min: 3,
                                              max: 100,
                                              get: { [unowned self] in self.radius },
                                              set: { [unowned self] in
                                                self.radius = $0
                                                self.drawExampleCircle = true
        })
        return [radiusVariable]
    }
}
