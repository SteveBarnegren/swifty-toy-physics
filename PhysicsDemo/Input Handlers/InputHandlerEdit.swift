//
//  InputHandlerEdit.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 25/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

private let grabDistance = 5.0

private struct EditHandle {
    let point: Vector2D
    let setter: (Vector2D) -> Void
}

private struct DeletionCandidate {
    let distance: Double
    let commit: () -> Void
}

class InputHandlerEdit: InputHandler {
    
    override var instruction: String? {
        "Drag handles to move. Right click to delete."
    }
    
    private var currentHandle: EditHandle?
    private var deleteLocation: Vector2D?
    
    // MARK: - Left mouse (move handles)

    override func mouseDown(at position: Vector2D, context: InputHandlerContext) {
        
        let closestHandle = getHandles(simulation: context.simulation)
            .sortedAscendingBy { $0.point.distance(to: position) }
            .first
        
        guard let handle = closestHandle else {
            return
        }
        
        if handle.point.distance(to: position) <= grabDistance {
            self.currentHandle = handle
        }
    }
    
    override func mouseDragged(to position: Vector2D, context: InputHandlerContext) {
        currentHandle?.setter(position)
    }
    
    override func mouseUp(at position: Vector2D, context: InputHandlerContext) {
        currentHandle?.setter(position)
        currentHandle = nil
    }
    
    private func getHandles(simulation: PhysicsSimulation) -> [EditHandle] {
        return getLineHandles(simulation: simulation)
    }
    
    private func getLineHandles(simulation: PhysicsSimulation) -> [EditHandle] {
        
        var handles = [EditHandle]()
        
        for line in simulation.lines {
            handles.append(
                EditHandle(point: line.start, setter: { line.start = $0 })
            )
            handles.append(
                EditHandle(point: line.end, setter: { line.end = $0 })
            )
        }
        
        return handles
    }
    
    // MARK: - Right Mouse (delete items)

    override func rightMouseDown(at position: Vector2D, context: InputHandlerContext) {
        deleteLocation = position
    }
    
    override func rightMouseDragged(to position: Vector2D, context: InputHandlerContext) {
        if let initialPosition = deleteLocation, position.distance(to: initialPosition) > grabDistance {
            deleteLocation = nil
        }
    }
    
    override func rightMouseUp(at position: Vector2D, context: InputHandlerContext) {
        if let location = deleteLocation {
            deleteItem(atLocation: location, simulation: context.simulation)
        }
        deleteLocation = nil
    }
    
    private func deleteItem(atLocation deleteLocation: Vector2D, simulation: PhysicsSimulation) {

        let candidates = lineDeletionCandidates(location: deleteLocation, simultation: simulation)
        
        let candidate = candidates
            .sortedAscendingBy { $0.distance }
            .first
        
        if let c = candidate, c.distance <= grabDistance {
            c.commit()
        }
    }
    
    private func lineDeletionCandidates(location: Vector2D, simultation: PhysicsSimulation) -> [DeletionCandidate] {
        
        return simultation.lines.map { line in
            DeletionCandidate(distance: Math.distanceFromPointToLine(point: location, start: line.start, end: line.end),
                              commit: { simultation.lines.removeAll(where: { $0 === line }) })
        }
    }
    
    // MARK: - Key handling
    
    override func keyDown(key: KeyboardKey) {
        if key == .esc {
            escapePressed()
        }
    }
    
    private func escapePressed() {
        if currentHandle == nil {
            delegate?.inputHandlerDidFinish(handler: self)
        } else {
            currentHandle = nil
        }
    }
    
    // MARK: - Objects to render
    
    override func objectsToRender(context: InputHandlerContext) -> [DrawableObject] {
        
        // Draw a handles at each edit point
        let points = context.simulation.lines.map { [$0.start, $0.end] }.joined()
        
        return points.map {
            var circle = CircleObject(position: NSPoint(x: $0.x, y: $0.y), radius: 2)
            circle.color = .magenta
            return .circle(circle)
        }
    }
}