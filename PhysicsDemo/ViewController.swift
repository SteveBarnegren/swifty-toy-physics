//
//  ViewController.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa

let simulationSize = Vector2D(400, 300)
let ballRadius = 5.0

class ViewController: NSViewController {
    
    @IBOutlet private var simulationView: SimulationView!
    
    private var simulation: PhysicsSimulation!
    
    private var isObservingDisplayLink = false
    
    private var inputHandler = InputHandlerFlingBall()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simulationView.delegate = self
        
        // Create physics simulation
        simulation = PhysicsSimulation()
        simulation.gravity = -10
        
        // Add bottom Boundary
        let bottomBoundary = Boundary(orientation: .minY)
        bottomBoundary.value = 20
        simulation.add(boundary: bottomBoundary)
        
        // Add right Boundary
        let rightBoundary = Boundary(orientation: .maxX)
        rightBoundary.value = simulationSize.width - 20
        simulation.add(boundary: rightBoundary)
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
        
        simulation.step(dt: dt)
        render()
    }
    
    private func render() {
        simulationView.render(simulation: simulation,
                           simulationSize: simulationSize,
                           additionalObjects: inputHandler.objectsToRender())
    }
}

extension ViewController: SimulationViewDelegate {
    
    var inputHandlerContext: InputHandlerContext {
        return InputHandlerContext(simulation: simulation, simulationSize: simulationSize)
    }
    
    func mouseDown(at location: Vector2D) {
        inputHandler.mouseDown(at: location, context: inputHandlerContext)
    }
    
    func mouseDragged(to location: Vector2D) {
        inputHandler.mouseDragged(to: location, context: inputHandlerContext)
    }
    
    func mouseUp(at location: Vector2D) {
        inputHandler.mouseUp(at: location, context: inputHandlerContext)
    }
}

