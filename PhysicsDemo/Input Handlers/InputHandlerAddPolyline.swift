//
//  InputHandlerAddPolyLine.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 01/07/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class InputHandlerAddPolyline: InputHandler {
    
    override var instruction: String? {
        "Click to add points"
    }
    
    enum Model {
        case empty
        case line(points: [Vector2D])
        
        var points: [Vector2D] {
            switch self {
            case .empty:
                return []
            case .line(let points):
                return points
            }
        }
        
        func adding(point: Vector2D) -> Model {
            switch self {
            case .empty:
                return .line(points: [point])
            case .line(points: let points):
                return .line(points: points.appending(point))
            }
        }
    }
    
    var mousePosition: Vector2D?
    
    var model = Model.empty
    
    // MARK: - Mouse
    
    override func mouseDown(at position: InputPosition, context: InputHandlerContext) {
        mousePosition = position.gridPosition
    }
    
    override func mouseDragged(to position: InputPosition, context: InputHandlerContext) {
        mousePosition = position.gridPosition
    }
    
    override func mouseUp(at position: InputPosition, context: InputHandlerContext) {
        model = model.adding(point: position.gridPosition)
    }
    
    override func mouseMoved(to position: InputPosition, context: InputHandlerContext) {
        mousePosition = position.gridPosition
        print("Mouse moved: \(position.gridPosition)")
    }
    
    // MARK: - Keyboard
    
    override func keyDown(key: KeyboardKey, simulation: PhysicsSimulation) {
        switch key {
        case .enter:
            enterPressed(simulation: simulation)
        case .esc:
            escapePressed()
        default:
            break
        }
    }
    
    private func enterPressed(simulation: PhysicsSimulation) {
        let points = model.points
        guard points.count >= 2 else {
            print("Polyline must have at least two points")
            return
        }
        
        let polyline = PhysicsPolyline(points: points)
        simulation.add(polyline: polyline)
        
        self.model = .empty
    }
    
    private func escapePressed() {
        switch model {
        case .empty:
            delegate?.inputHandlerDidFinish(handler: self)
        case .line:
            self.model = .empty
        }
    }
    
    // MARK: - Render
    
    override func objectsToRender(context: InputHandlerContext) -> [DrawCommand] {
        
        let points = model.points
        
        if points.isEmpty {
            return []
        }
        
        var commands = [DrawCommand]()
        
        // Draw lines between points
        for (point, nextPoint) in zip(points, points.dropFirst()) {
            var line = LineDrawCommand(from: point.nsPoint, to: nextPoint.nsPoint)
            line.color = .white
            commands.append(.line(line))
        }
        
        // Draw line to the current mouse position
        if let lastPoint = points.last, let mousePosition = self.mousePosition {
            var line = LineDrawCommand(from: lastPoint.nsPoint, to: mousePosition.nsPoint)
            line.color = .lightGray
            commands.append(.line(line))
        }
        
        // Draw points
        for point in model.points {
            var circle = CircleDrawCommand(position: point, radius: 2)
            circle.color = .blue
            commands.append(.circle(circle))
        }
        
        return commands
    }
}
