//
//  InputHandlerEdit.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 25/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

private let grabDistance = 5.0

private protocol EditPoint {
    var point: Vector2D { get }
}

private struct EditHandle: EditPoint {
    let point: Vector2D
    let setter: (Vector2D) -> Void
    var color = NSColor.magenta
}

private struct EditButton: EditPoint {
    let point: Vector2D
    let isEnabled: Bool
    let setter: (Bool) -> Void
    var color = NSColor.yellow
}

private struct DeletionCandidate {
    let distance: Double
    let commit: () -> Void
}

class InputHandlerEdit: InputHandler {
    
    private enum State {
        case idle
        case draggingHandle(EditHandle)
        case pressingButton(EditButton)
    }
    
    override var instruction: String? {
        "Drag handles to move. Right click to delete."
    }
    
    private var state = State.idle
    private var deleteLocation: Vector2D?
    private var boundaries: [Boundary]
    
    init(boundaries: [Boundary]) {
        self.boundaries = boundaries
    }
    
    // MARK: - Left mouse (move handles)

    override func mouseDown(at position: InputPosition, context: InputHandlerContext) {
        
        let allEditPoints: [EditPoint] = getHandles(simulation: context.simulation)
                + getBoundaryToggleButtons(simSize: simulationSize)
        
        let closestEditPoint = allEditPoints
            .sortedAscendingBy { $0.point.distance(to: position.position) }
            .first
        
        guard let editPoint = closestEditPoint else {
            return
        }
        
        guard editPoint.point.distance(to: position.position) <= grabDistance else {
            self.state = .idle
            return
        }
        
        if let handle = editPoint as? EditHandle {
            self.state = .draggingHandle(handle)
        } else if let button = editPoint as? EditButton {
            self.state = .pressingButton(button)
        }
    }
    
    override func mouseDragged(to position: InputPosition, context: InputHandlerContext) {
        
        switch self.state {
        case .idle:
            return
        case .draggingHandle(let handle):
            handle.setter(position.gridPosition)
        case .pressingButton:
            return
        }
    }
    
    override func mouseUp(at position: InputPosition, context: InputHandlerContext) {
        
        switch self.state {
        case .idle:
            return
        case .draggingHandle(let handle):
            return
        case .pressingButton(let button):
            button.setter(!button.isEnabled)
        }
        
        self.state = .idle
    }
    
    // MARK: - Create handles
    
    private func getHandles(simulation: PhysicsSimulation) -> [EditHandle] {
        return getLineHandles(simulation: simulation) + getCircleHandles(simulation: simulation)
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
    
    private func getCircleHandles(simulation: PhysicsSimulation) -> [EditHandle] {
        
        var handles = [EditHandle]()
        
        for circle in simulation.circles {
            handles.append(
                EditHandle(point: circle.position, setter: { circle.position = $0 })
            )
            handles.append(
                EditHandle(point: circle.position.adding(x: circle.radius),
                           setter: { circle.radius = ($0.x - circle.position.x).constrained(min: 2) },
                           color: .orange)
            )
        }
        
        return handles
    }
    
    private func getBoundaryToggleButtons(simSize: Vector2D) -> [EditButton] {
        var buttons = [EditButton]()
        
        for boundary in boundaries {
            let button = EditButton(point: toggleLocation(forBoundary: boundary, simSize: simSize),
                                    isEnabled: boundary.isEnabled,
                                    setter: { boundary.isEnabled = $0 },
                                    color: .yellow)
            buttons.append(button)
        }
        return buttons
    }
    
    // MARK: - Create toggle buttons
    
    private func toggleLocation(forBoundary boundary: Boundary, simSize: Vector2D) -> Vector2D {
        
        switch boundary.orientation {
        case .minX:
            return Vector2D(boundary.value/2, simSize.height/2)
        case .maxX:
            return Vector2D((simSize.width + boundary.value)/2, simSize.height/2)
        case .minY:
            return Vector2D(simSize.width/2, boundary.value/2)
        case .maxY:
            return Vector2D(simSize.width/2, (simSize.height + boundary.value)/2)
        }
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
                + circleDeletionCandidates(location: deleteLocation, simulation: simulation)
        
        let candidate = candidates
            .sortedAscendingBy { $0.distance }
            .first
        
        if let c = candidate, c.distance <= grabDistance {
            c.commit()
        }
    }
    
    private func lineDeletionCandidates(location: Vector2D, simultation: PhysicsSimulation) -> [DeletionCandidate] {
        
        return simultation.lines.map { line in
            let distance = VectorMath.distanceFromPointToLineSegment(point: location,
                                                                     start: line.start,
                                                                     end: line.end)
            return DeletionCandidate(distance: distance,
                                     commit: { simultation.lines.removeAll(where: { $0 === line }) })
        }
    }
    
    private func circleDeletionCandidates(location: Vector2D, simulation: PhysicsSimulation) -> [DeletionCandidate] {
        
        return simulation.circles.map { circle in
            DeletionCandidate(distance: circle.position.distance(to: location),
                              commit: { simulation.remove(circle: circle) })
        }
    }
    
    // MARK: - Key handling
    
    override func keyDown(key: KeyboardKey) {
        if key == .esc {
            escapePressed()
        }
    }
    
    
    
    private func escapePressed() {
        
        switch state {
        case .idle:
            delegate?.inputHandlerDidFinish(handler: self)
        default:
            self.state = .idle
        }
    }
    
    // MARK: - Objects to render
    
    override func objectsToRender(context: InputHandlerContext) -> [DrawCommand] {
        
        // Edit handles
        let handleCommands: [DrawCommand] = getHandles(simulation: context.simulation).map {
            var circle = CircleDrawCommand(position: $0.point, radius: 2)
            circle.color = $0.color
            return .circle(circle)
        }
        
        // Buttons
        var buttonCommands = [DrawCommand]()
        for button in getBoundaryToggleButtons(simSize: context.simulationSize) {
            var circle = CircleDrawCommand(position: button.point,
                                           radius: 2,
                                           drawStyle: button.isEnabled ? .fill : .stroke)
            circle.color = button.color
            
            buttonCommands.append(.circle(circle))
        }
        
        return handleCommands + buttonCommands
    }
}
