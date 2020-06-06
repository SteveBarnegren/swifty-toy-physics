//
//  PhysicsRenderingView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

private let lineThickness = 2.0

protocol SimulationViewDelegate: class {
    func mouseDown(at location: Vector2D)
    func mouseDragged(to location: Vector2D)
    func mouseUp(at location: Vector2D)
    func rightMouseDown(at location: Vector2D)
    func rightMouseDragged(to location: Vector2D)
    func rightMouseUp(at location: Vector2D)
}

class SimulationView: NSView {
    
    weak var delegate: SimulationViewDelegate?
    
    private var simulation: PhysicsSimulation?
    private var simulationSize = Vector2D.zero
    private var objects = [DrawCommand]()
    
    // MARK: - Render simulation
    
    func render(simulation: PhysicsSimulation, simulationSize: Vector2D, additionalObjects: [DrawCommand]) {
        self.simulation = simulation
        self.simulationSize = simulationSize
        
        objects.removeAll()
        objects += simulation.boundaries.map { makeObject(for: $0, simulationSize: simulationSize) }
        objects += simulation.lines.map(makeObject)
        objects += simulation.balls.map(makeObject)
        objects += simulation.circles.map(makeObject)
        objects += additionalObjects
        objects += GridManager.shared.drawCommands(forSimulationSize: simulationSize)
        
        needsDisplay = true
    }
    
    private func makeObject(for boundary: Boundary, simulationSize: Vector2D) -> DrawCommand {
        
        let start: NSPoint
        let end: NSPoint
        
        switch boundary.orientation {
        case .minX, .maxX:
            start = NSPoint(x: boundary.value, y: 0)
            end = NSPoint(x: boundary.value, y: simulationSize.height)
        case .minY, .maxY:
            start = NSPoint(x: 0, y: boundary.value)
            end = NSPoint(x: simulationSize.width, y: boundary.value)
        }
        
        let line = LineDrawCommand(from: start, to: end)
        return .line(line)
    }
    
    private func makeObject(for ball: Ball) -> DrawCommand {
        
        let circle = CircleDrawCommand(position: ball.position, radius: ball.radius)
        return .circle(circle)
    }
    
    private func makeObject(for physicsLine: PhysicsLine) -> DrawCommand {
        
        let start = NSPoint(x: physicsLine.start.x, y: physicsLine.start.y)
        let end = NSPoint(x: physicsLine.end.x, y: physicsLine.end.y)
        
        let line = LineDrawCommand(from: start, to: end, color: .white, strokeWidth: 1)
        return .line(line)
    }
    
    private func makeObject(for physicsCircle: PhysicsCircle) -> DrawCommand {
        
        let command = CircleDrawCommand(position: physicsCircle.position,
                                        radius: physicsCircle.radius,
                                        color: .white,
                                        drawStyle: .stroke)
        return .circle(command)
    }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw view background
        NSColor.white.set()
        NSBezierPath(rect: bounds).fill()
        
        guard simulationSize != Vector2D.zero else {
            return
        }
        
        // Draw simulation background
        let simulationRect = aspectFit(size: simulationSize.cgSize, inSize: bounds.size)
        NSColor.black.set()
        NSBezierPath(rect: simulationRect).fill()
        
        // Draw objects
        objects.forEach(draw)
    }
    
    private func draw(object: DrawCommand) {
        switch object {
        case .line(let line):
            draw(line: line)
        case .circle(let circle):
            draw(circle: circle)
        case .rect(let rect):
            draw(rect: rect)
        }
    }
    
    private func draw(line: LineDrawCommand) {
        
        let from = convertPoint(simToView: line.from)
        let to = convertPoint(simToView: line.to)
        
        line.color.set()
        
        let path = NSBezierPath()
        path.lineWidth = lineThickness.cgf
        path.move(to: from)
        path.line(to: to)
        path.stroke()
    }
    
    private func draw(circle: CircleDrawCommand) {
        
        let rect = NSRect(x: (circle.position.x - circle.radius).cgf,
                          y: (circle.position.y - circle.radius).cgf,
                          width: circle.radius.cgf*2,
                          height: circle.radius.cgf*2)
        let convertedRect = convertRect(simToView: rect)
        
        circle.color.set()
        let path = NSBezierPath(ovalIn: convertedRect)
        switch circle.drawStyle {
        case .stroke:
            path.lineWidth = lineThickness.cgf
            path.stroke()
        case .fill:
            path.fill()
        }
    }
    
    private func draw(rect: RectDrawCommand) {
        
        let nsRect = NSRect(x: rect.origin.x,
                            y: rect.origin.y,
                            width: rect.size.width,
                            height: rect.size.height)
        let convertedRect = convertRect(simToView: nsRect)

        rect.color.set()
        let path = NSBezierPath(rect: convertedRect)
        switch rect.drawStyle {
        case .stroke:
            path.lineWidth = lineThickness.cgf
            path.stroke()
        case .fill:
            path.fill()
        }
    }
    
    // MARK: - Mouse handling
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        delegate?.mouseDown(at: simulationLocation(fromEvent: event))
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        delegate?.mouseDragged(to: simulationLocation(fromEvent: event))
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        delegate?.mouseUp(at: simulationLocation(fromEvent: event))
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        delegate?.rightMouseDown(at: simulationLocation(fromEvent: event))
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        super.rightMouseDragged(with: event)
        delegate?.rightMouseDragged(to: simulationLocation(fromEvent: event))
    }
    
    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        delegate?.rightMouseUp(at: simulationLocation(fromEvent: event))
    }
    
    private func simulationLocation(fromEvent event: NSEvent) -> Vector2D {
        
        let locationInView = convert(event.locationInWindow, from: nil)
        let point = convertPoint(viewToSim: locationInView)
        return Vector2D(point)
    }
    
    // MARK: - Coordinate conversion
    
    func convertPoint(viewToSim p: NSPoint) -> NSPoint {
        
        var p = p
        
        // Translate to simulation rect
        p.x -= simulationRect.minX
        p.y -= simulationRect.minY
        
        // Calculate rect pct
        let xPct = p.x / simulationRect.width
        let yPct = p.y / simulationRect.height
        
        // Convert to simulation space
        let simX = simulationSize.width.cgf * xPct
        let simY = simulationSize.height.cgf * yPct
        
        return NSPoint(x: simX, y: simY)
    }
    
    private func convertPoint(simToView p: NSPoint) -> NSPoint {
        
        let xPct = p.x / CGFloat(simulationSize.width)
        let yPct = p.y / CGFloat(simulationSize.height)
        
        return NSPoint(x: simulationRect.minX + simulationRect.width*xPct,
                       y: simulationRect.minY + simulationRect.height*yPct)
    }
    
    private func convertRect(simToView r: NSRect) -> NSRect {
        
        let xPct = r.origin.x / simulationSize.width.cgf
        let yPct = r.origin.y / simulationSize.height.cgf
        let widthPct = r.size.width / simulationSize.width.cgf
        let heightPct = r.size.height / simulationSize.height.cgf
        
        return NSRect(x: simulationRect.minX + simulationRect.width*xPct,
                      y: simulationRect.minY + simulationRect.height*yPct,
                      width: simulationRect.width * widthPct,
                      height: simulationRect.height * heightPct)
    }
    
    private func aspectFit(size: NSSize, inSize parentSize: NSSize) -> NSRect {
        
        // Try to fit to parent width
        if parentSize.width * size.wTohRatio <= parentSize.height {
            let height = parentSize.width * size.wTohRatio
            let y = parentSize.height/2 - height/2
            return NSRect(x: 0, y: y, width: parentSize.width, height: height)
        }
            // Fit to parent height
        else {
            let width = parentSize.height * size.hTowRatio
            let x = parentSize.width/2 - width/2
            return NSRect(x: x, y: 0, width: width, height: parentSize.height)
        }
    }
    
    var simulationRect: CGRect {
        return aspectFit(size: simulationSize.cgSize, inSize: bounds.size)
    }
}

extension NSSize {
    var hTowRatio: CGFloat {
        width / height
    }
    
    var wTohRatio: CGFloat {
        height / width
    }
}

