//
//  PhysicsRenderingView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

struct LineObject {
    let from: NSPoint
    let to: NSPoint
    var color = NSColor.white
    var strokeWidth = 1.0
}

struct CircleObject {
    let position: NSPoint
    let radius: Double
    var color = NSColor.white
}

enum DrawableObject {
    case line(LineObject)
    case circle(CircleObject)
}

class PhysicsRenderingView: NSView {
    
    private var simulation: PhysicsSimulation?
    private var simulationSize = Vector2D.zero
    private var objects = [DrawableObject]()
    
    // MARK: - Render
    
    func render(simulation: PhysicsSimulation, simulationSize: Vector2D, additionalObjects: [DrawableObject]) {
        self.simulation = simulation
        self.simulationSize = simulationSize
        
        objects.removeAll()
        objects += additionalObjects
        objects += simulation.boundaries.map { makeObject(for: $0, simulationSize: simulationSize) }
        objects += simulation.balls.map(makeObject)
        
        needsDisplay = true
    }
    
    private func makeObject(for boundary: Boundary, simulationSize: Vector2D) -> DrawableObject {
        
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
        
        let line = LineObject(from: start, to: end)
        return .line(line)
    }
    
    private func makeObject(for ball: Ball) -> DrawableObject {
        
        let pos = NSPoint(x: ball.position.x, y: ball.position.y)
        let circle = CircleObject(position: pos, radius: ball.radius)
        return .circle(circle)
    }
    
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
    
    private func draw(object: DrawableObject) {
        switch object {
        case .line(let line):
            draw(line: line)
        case .circle(let circle):
            draw(circle: circle)
        }
    }
    
    private func draw(line: LineObject) {
        
        let from = convertPoint(simToView: line.from)
        let to = convertPoint(simToView: line.to)
        
        line.color.set()
        
        let path = NSBezierPath()
        path.lineWidth = line.strokeWidth.cgf
        path.move(to: from)
        path.line(to: to)
        path.stroke()
    }
    
    private func draw(circle: CircleObject) {
        
        let rect = NSRect(x: circle.position.x - circle.radius.cgf,
                          y: circle.position.y - circle.radius.cgf,
                          width: circle.radius.cgf*2,
                          height: circle.radius.cgf*2)
        let convertedRect = convertRect(simToView: rect)
        
        circle.color.set()
        let path = NSBezierPath(ovalIn: convertedRect)
        path.fill()
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

