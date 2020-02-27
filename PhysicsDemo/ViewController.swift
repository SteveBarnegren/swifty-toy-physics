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
    @IBOutlet private var placementStyleSegmentedControl: NSSegmentedControl!
    @IBOutlet private var instructionLabel: NSTextField!
    
    private var simulation: PhysicsSimulation!
    
    private var isObservingDisplayLink = false
    
    private var inputHandlerStack = [InputHandler]()
    private var inputHandler: InputHandler {
        return inputHandlerStack.last!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simulationView.delegate = self
        (view as! MainView).keyHandler = self
        
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
        
        // Setup input handlers
        let baseInputHandler = InputHandlerSwitch(handlers: [
            InputHandlerPlaceBall(),
            InputHandlerFlingBall()
        ], currentIndex: { [unowned self] in self.placementStyleSegmentedControl.indexOfSelectedItem })
        
        pushInputHandler(baseInputHandler)
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
                           additionalObjects: inputHandler.objectsToRender(context: inputHandlerContext))
    }
    
    // MARK: - Actions
    
    @IBAction private func placementStyleSegmentedControlChanged(sender: NSSegmentedControl) {
        popToRootInputHandler()
    }
    
    @IBAction private func addLineButtonPressed(sender: NSButton) {
        pushInputHandler(InputHandlerPlacePhysicsLine())
    }
    
    @IBAction private func editButtonPressed(sender: NSButton) {
        pushInputHandler(InputHandlerEdit())
    }
    
    // MARK: - Key handling
    
    override func keyDown(with event: NSEvent) {
        if let key = KeyboardKey(keyCode: event.keyCode) {
            inputHandler.keyDown(key: key)
        }
    }
    
    // MARK: - Input Handlers
    
    private func pushInputHandler(_ handler: InputHandler) {
        handler.delegate = self
        inputHandlerStack.append(handler)
        updateInstructionLabel()
    }
    
    private func popInputHandler() {
        inputHandlerStack.removeLast()
        updateInstructionLabel()
    }
    
    private func popToRootInputHandler() {
        inputHandlerStack.removeSubrange(1...)
        updateInstructionLabel()
    }
    
    // MARK: - Instruction
    
    private func updateInstructionLabel() {
        if let instruction = inputHandler.instruction {
            instructionLabel.stringValue = instruction
        } else {
            instructionLabel.stringValue = ""
        }
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
    
    func rightMouseDown(at location: Vector2D) {
        inputHandler.rightMouseDown(at: location, context: inputHandlerContext)
    }
    
    func rightMouseDragged(to location: Vector2D) {
        inputHandler.rightMouseDragged(to: location, context: inputHandlerContext)
    }
    
    func rightMouseUp(at location: Vector2D) {
        inputHandler.rightMouseUp(at: location, context: inputHandlerContext)
    }
}

extension ViewController: InputHandlerDelegate {
    
    func inputHandlerDidFinish(handler: InputHandler) {
        popInputHandler()
    }
}
