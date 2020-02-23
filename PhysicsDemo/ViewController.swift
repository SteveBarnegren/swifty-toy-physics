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

let simulationSize = Vector2D(400, 300)
let ballRadius = 5.0

class ViewController: NSViewController {
    
    @IBOutlet private var physicsView: PhysicsRenderingView!
    
    private var physicsWorld: PhysicsWorld!
    
    private var isObservingDisplayLink = false
    
    private var touchState = TouchState.idle
    private var inputHandler = InputHandlerFlingBall()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create physics world
        physicsWorld = PhysicsWorld()
        physicsWorld.gravity = -10
        
        // Add bottom Boundary
        let bottomBoundary = Boundary(orientation: .minY)
        bottomBoundary.value = 20
        physicsWorld.add(boundary: bottomBoundary)
        
        // Add right Boundary
        let rightBoundary = Boundary(orientation: .maxX)
        rightBoundary.value = simulationSize.width - 20
        physicsWorld.add(boundary: rightBoundary)
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
        render()
    }
    
    private func tick(dt: Double) {
        
        physicsWorld.step(dt: dt)
        render()
    }
    
    private func render() {
        physicsView.render(world: physicsWorld,
                           simulationSize: simulationSize,
                           additionalObjects: inputHandler.objectsToRender())
    }
    
    // MARK: - Mouse handling
    
    var inputHandlerContext: InputHandlerContext {
        return InputHandlerContext(world: physicsWorld, simulationSize: simulationSize)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
   
        inputHandler.mouseDown(at: simulationLocation(from: event),
                               context: inputHandlerContext)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
   
        inputHandler.mouseDragged(to: simulationLocation(from: event),
                               context: inputHandlerContext)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
   
        inputHandler.mouseUp(at: simulationLocation(from: event),
                               context: inputHandlerContext)
    }
        
    private func simulationLocation(from event: NSEvent) -> Vector2D {
        let windowPos = event.locationInWindow
        let viewPos = physicsView.convert(windowPos, from: view)
        return physicsView.convertPoint(viewToWorld: viewPos).vector2D
    }
}

