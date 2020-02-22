//
//  ViewController.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa

private enum TouchState {
    case idle
    case holdingBall(Ball)
}

class ViewController: NSViewController {
    
    @IBOutlet private var physicsView: PhysicsRenderingView!
    
    private var physicsWorld: PhysicsWorld!
    
    private var isObservingDisplayLink = false
    
    private var touchState = TouchState.idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create physics world
        physicsWorld = PhysicsWorld()
        physicsWorld.gravity = -10
        
        // Add a ball
        let ball = Ball(radius: 5)
        ball.position = Vector2D(100, 100)
        ball.affectedByPhysics = true
        physicsWorld.add(ball: ball)
        
        // Add bottom Boundary
        let bottomBoundary = Boundary(orientation: .minY)
        bottomBoundary.value = 20
        physicsWorld.add(boundary: bottomBoundary)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Observe display link
        if !isObservingDisplayLink {
            DisplayLink.shared.add(observer: { [weak self] in
                self?.tick(dt: $0)
            })
            isObservingDisplayLink = true
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        physicsView.render(world: physicsWorld)
    }
    
    private func tick(dt: Double) {
        
        physicsWorld.step(dt: dt)
        physicsView.render(world: physicsWorld)
    }
    
    // MARK: - Mouse handling
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let pos = location(from: event)
        print("Down: \(pos)")
        
        physicsWorld.removeAllBalls()
        
        let ball = Ball(radius: 5)
        ball.position = Vector2D(pos)
        ball.affectedByPhysics = false
        physicsWorld.add(ball: ball)
        
        self.touchState = .holdingBall(ball)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        let pos = location(from: event)
        print("Dragged: \(pos)")
        
        switch touchState {
        case .idle:
            return
        case .holdingBall(let ball):
            ball.position = Vector2D(pos)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        let pos = location(from: event)
        print("Up: \(pos)")
        
        switch touchState {
        case .idle:
            return
        case .holdingBall(let ball):
            ball.position = Vector2D(pos)
            ball.affectedByPhysics = true
        }
    }
    
    private func location(from event: NSEvent) -> NSPoint {
        let windowPos = event.locationInWindow
        let viewPos = physicsView.convert(windowPos, from: view)
        return viewPos
    }
}

