//
//  PhysicsRenderingView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit
import SBSwiftUtils

private let lineThickness = 2.0

protocol SimulationViewDelegate: class {
    func mouseDown(at location: Vector2D)
    func mouseDragged(to location: Vector2D)
    func mouseUp(at location: Vector2D)
    func rightMouseDown(at location: Vector2D)
    func rightMouseDragged(to location: Vector2D)
    func rightMouseUp(at location: Vector2D)
    func mouseMoved(to location: Vector2D)
}

class SimulationView: NSView {
    
    weak var delegate: SimulationViewDelegate?
    
    private var simulation: PhysicsSimulation?
    private var simulationSize = Vector2D.zero
    private var objects = [DrawCommand]()
    private var trackingArea: NSTrackingArea?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        updateTrackingAreas()
    }
    
    // MARK: - Render simulation
    
    func render(simulation: PhysicsSimulation,
                simulationSize: Vector2D,
                additionalObjects: [DrawCommand],
                remainingInterpolationTime: Double) {
        self.simulation = simulation
        self.simulationSize = simulationSize
        
        objects.removeAll()
        objects += makeDrawCommands(forBoundaries: simulation.boundaries, simulationSize: simulationSize)
        objects += simulation.lines.map(makeObject)
        objects += simulation.balls.map { makeObject(for: $0, interploationTime: remainingInterpolationTime) }
        objects += simulation.circles.map(makeObject)
        objects += simulation.polyLines.map(makeDrawCommands).joined()
        objects += additionalObjects
        objects += GridManager.shared.drawCommands(forSimulationSize: simulationSize)
        
        needsDisplay = true
    }
    
    private func makeDrawCommands(forBoundaries boundaries: [Boundary], simulationSize: Vector2D) -> [DrawCommand] {
        
        let boundaries = boundaries.filter { $0.isEnabled }
        
        let minX = boundaries.first { $0.orientation == .minX }?.value ?? 0
        let maxX = boundaries.first { $0.orientation == .maxX }?.value ?? simulationSize.width
        let minY = boundaries.first { $0.orientation == .minY }?.value ?? 0
        let maxY = boundaries.first { $0.orientation == .maxY }?.value ?? simulationSize.height
        
        var commands = [DrawCommand]()
        
        for boundary in boundaries {
            let start: NSPoint
            let end: NSPoint
            
            switch boundary.orientation {
            case .minX, .maxX:
                start = NSPoint(x: boundary.value, y: minY)
                end = NSPoint(x: boundary.value, y: maxY)
            case .minY, .maxY:
                start = NSPoint(x: minX, y: boundary.value)
                end = NSPoint(x: maxX, y: boundary.value)
            }
            
            let line = LineDrawCommand(from: start, to: end)
            commands.append(.line(line))
        }
        
        return commands
    }
    
    private func makeObject(for ball: Ball, interploationTime: Double) -> DrawCommand {
        
        let ballPosition = ball.position + (ball.velocity * interploationTime)
        
        let circle = CircleDrawCommand(position: ballPosition, radius: ball.radius)
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
    
    private func makeDrawCommands(for polyline: PhysicsPolyline) -> [DrawCommand] {
        
        var commands = [DrawCommand]()
        
        for (point, nextPoint) in zip(polyline.points, polyline.points.dropFirst()) {
            let line = LineDrawCommand(from: point.nsPoint, to: nextPoint.nsPoint)
            commands.append(.line(line))
        }
        return commands
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
    
    override func updateTrackingAreas() {
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
            self.trackingArea = nil
        }
        
        let ta = NSTrackingArea(rect: self.bounds,
                                options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
                                owner: self,
                                userInfo: nil)
        addTrackingArea(ta)
        self.trackingArea = ta
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
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        delegate?.mouseMoved(to: simulationLocation(fromEvent: event))
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

