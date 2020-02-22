//
//  PhysicsRenderingView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

class PhysicsRenderingView: NSView {
    
    private var physicsWorld: PhysicsWorld?
    
    func render(world: PhysicsWorld) {
        self.physicsWorld = world
        needsDisplay = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        NSColor.black.set()
        NSBezierPath(rect: bounds).fill()
        
        guard let physicsWorld = self.physicsWorld else {
            return
        }
        
        physicsWorld.balls.forEach(draw)
        physicsWorld.boundaries.forEach(draw)
    }
    
    private func draw(ball: Ball) {
        
        NSColor.orange.set()
        
        let rect = NSRect(x: ball.position.x - ball.radius,
                          y: ball.position.y - ball.radius,
                          width: ball.radius*2,
                          height: ball.radius*2)
        let path = NSBezierPath(ovalIn: rect)
        path.fill()
    }
    
    private func draw(boundary: Boundary) {
        
        let start: NSPoint
        let end: NSPoint
        
        switch boundary.orientation {
        case .minX, .maxX:
            start = NSPoint(x: boundary.value, y: Double(bounds.minY))
            end = NSPoint(x: boundary.value, y: Double(bounds.maxY))
        case .minY, .maxY:
            start = NSPoint(x: Double(bounds.minX), y: boundary.value)
            end = NSPoint(x: Double(bounds.maxX), y: boundary.value)
        }
        
        NSColor.white.set()
        
        let path = NSBezierPath()
        path.lineWidth = 1
        path.move(to: start)
        path.line(to: end)
        path.stroke()
    }
}

