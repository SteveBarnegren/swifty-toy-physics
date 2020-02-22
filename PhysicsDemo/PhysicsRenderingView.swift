//
//  PhysicsRenderingView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

private struct LineObject {
    let from: NSPoint
    let to: NSPoint
    var color = NSColor.white
    var strokeWidth = 1.0
}

private struct CircleObject {
    let position: NSPoint
    let radius: Double
    var color = NSColor.white
}

private enum DrawableObject {
    case line(LineObject)
    case circle(CircleObject)
}

class PhysicsRenderingView: NSView {
    
    private var physicsWorld: PhysicsWorld?
    private var worldSize = Vector2D.zero
    private var objects = [DrawableObject]()
    
    // MARK: - Render
    
    func render(world: PhysicsWorld, worldSize: Vector2D) {
        self.physicsWorld = world
        self.worldSize = worldSize
        
        objects.removeAll()
        objects += world.boundaries.map { makeObject(for: $0, worldSize: worldSize) }
        objects += world.balls.map(makeObject)
        
        needsDisplay = true
    }
    
    private func makeObject(for boundary: Boundary, worldSize: Vector2D) -> DrawableObject {
        
        let start: NSPoint
        let end: NSPoint
        
        switch boundary.orientation {
        case .minX, .maxX:
            start = NSPoint(x: boundary.value, y: 0)
            end = NSPoint(x: boundary.value, y: worldSize.height)
        case .minY, .maxY:
            start = NSPoint(x: 0, y: boundary.value)
            end = NSPoint(x: worldSize.width, y: boundary.value)
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
        
        guard worldSize != Vector2D.zero else {
            return
        }
        
        // Draw simulation background
        let worldRect = aspectFit(size: worldSize.cgSize, inSize: bounds.size)
        NSColor.black.set()
        NSBezierPath(rect: worldRect).fill()
        
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
        
        let from = convertPoint(worldToView: line.from)
        let to = convertPoint(worldToView: line.to)
        
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
        let convertedRect = convertRect(worldToView: rect)
        
        circle.color.set()
        let path = NSBezierPath(ovalIn: convertedRect)
        path.fill()
    }
    
    // MARK: - Coordinate conversion
    
    func convertPoint(viewToWorld p: NSPoint) -> NSPoint {
        
        var p = p
        
        // Translate to world rect
        p.x -= worldRect.minX
        p.y -= worldRect.minY
        
        // Calculate rect pct
        let xPct = p.x / worldRect.width
        let yPct = p.y / worldRect.height
        
        // Convert to simulation space
        let simX = worldSize.width.cgf * xPct
        let simY = worldSize.height.cgf * yPct
        
        return NSPoint(x: simX, y: simY)
    }
    
    private func convertPoint(worldToView p: NSPoint) -> NSPoint {
        
        let xPct = p.x / CGFloat(worldSize.width)
        let yPct = p.y / CGFloat(worldSize.height)
        
        return NSPoint(x: worldRect.minX + worldRect.width*xPct,
                       y: worldRect.minY + worldRect.height*yPct)
    }
    
    private func convertRect(worldToView r: NSRect) -> NSRect {
        
        let xPct = r.origin.x / worldSize.width.cgf
        let yPct = r.origin.y / worldSize.height.cgf
        let widthPct = r.size.width / worldSize.width.cgf
        let heightPct = r.size.height / worldSize.height.cgf
        
        return NSRect(x: worldRect.minX + worldRect.width*xPct,
                      y: worldRect.minY + worldRect.height*yPct,
                      width: worldRect.width * widthPct,
                      height: worldRect.height * heightPct)
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
    
    var worldRect: CGRect {
        return aspectFit(size: worldSize.cgSize, inSize: bounds.size)
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

