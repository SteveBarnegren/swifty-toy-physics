//
//  ViewController.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa

let simulationSize = Vector2D(400, 300)

class ViewController: NSViewController {
    
    @IBOutlet private var simulationView: SimulationView!
    @IBOutlet private var rightPanelContainerView: NSView!
    @IBOutlet private var placementStyleSegmentedControl: NSSegmentedControl!
    @IBOutlet private var instructionLabel: NSTextField!
    @IBOutlet private var gridPanelContainerView: NSView!
    
    private var variablesPanelView: VariablesPanelView?
    
    private var simulation: PhysicsSimulation!
    private var boundaries = [Boundary]()
    
    private var isObservingDisplayLink = false
    
    private var inputHandlerStack = [InputHandler]()
    private var inputHandler: InputHandler {
        return inputHandlerStack.last!
    }
    
    private var ballPlacementHandlers = [BallPlacementInputHandler]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simulationView.delegate = self
        (view as! MainView).keyHandler = self
        
        // Add the grid panel
        let gridPanel = GridPanelViewController()
        gridPanelContainerView.addSubview(gridPanel.view)
        addChild(gridPanel)
        gridPanel.view.pinToSuperviewEdges()
        
        // Create physics simulation
        simulation = PhysicsSimulation()
        simulation.gravity = -10
        
        // Add boundaries
        addSimulationBoundaries()
        
        // Setup input handlers
        ballPlacementHandlers = [InputHandlerPlaceBall(), InputHandlerFlingBall()]
        let baseInputHandler = InputHandlerSwitch(handlers: ballPlacementHandlers,
                                                  currentIndex: { [unowned self] in self.placementStyleSegmentedControl.indexOfSelectedItem
        })
        
        pushInputHandler(baseInputHandler)
    }
    
    func addSimulationBoundaries() {
        
        let inset = 20.0
        
        // Bottom
        let bottomBoundary = Boundary(orientation: .minY)
        bottomBoundary.value = inset
        simulation.add(boundary: bottomBoundary)
        boundaries.append(bottomBoundary)
        
        // Right
        let rightBoundary = Boundary(orientation: .maxX)
        rightBoundary.value = simulationSize.width - inset
        simulation.add(boundary: rightBoundary)
        boundaries.append(rightBoundary)
        
        // Top
        let topBoundary = Boundary(orientation: .maxY)
        topBoundary.value = simulationSize.height - inset
        simulation.add(boundary: topBoundary)
        boundaries.append(topBoundary)
        
        // Left
        let leftBoundary = Boundary(orientation: .minX)
        leftBoundary.value = inset
        simulation.add(boundary: leftBoundary)
        boundaries.append(leftBoundary)
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
        variablesPanelView?.frame = rightPanelContainerView.frame
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
    
    @IBAction private func addStaticCircleButtonPressed(sender: NSButton) {
        pushInputHandler(InputHandlerAddStaticCircles())
    }
    
    @IBAction private func editButtonPressed(sender: NSButton) {
        pushInputHandler(InputHandlerEdit(boundaries: self.boundaries))
    }
    
    @IBAction private func ballRadiusSliderValueChanged(sender: NSSlider) {
        ballPlacementHandlers.forEach { $0.ballRadius = sender.doubleValue }
    }
    
    @IBAction private func elasticitySliderValueChanged(sender: NSSlider) {
        print("Elasticity: \(sender.doubleValue)")
        ballPlacementHandlers.forEach { $0.ballElasticity = sender.doubleValue }
    }
    
    @IBAction private func enableBallCollisionsCheckboxChanged(sender: NSButton) {
        simulation.enableBallCollisions = (sender.state == .on)
    }
    
    // MARK: - Key handling
    
    override func keyDown(with event: NSEvent) {
        if let key = KeyboardKey(keyCode: event.keyCode) {
            inputHandler.keyDown(key: key)
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        
        var modifierKeys = [ModifierKey]()
        
        if event.modifierFlags.contains(.control) {
            modifierKeys.append(.control)
        }
        
        if event.modifierFlags.contains(.command) {
            modifierKeys.append(.command)
        }
        
        if event.modifierFlags.contains(.option) {
            modifierKeys.append(.option)
        }
        
        if event.modifierFlags.contains(.shift) {
            modifierKeys.append(.shift)
        }
        
        inputHandler.modifierKeysChanged(keys: modifierKeys)
    }
    
    // MARK: - Input Handlers
    
    private func pushInputHandler(_ handler: InputHandler) {
        handler.delegate = self
        inputHandlerStack.append(handler)
        inputHandlerChanged()
    }
    
    private func popInputHandler() {
        inputHandlerStack.removeLast()
        inputHandlerChanged()
    }
    
    private func popToRootInputHandler() {
        inputHandlerStack.removeSubrange(1...)
        inputHandlerChanged()
    }
    
    private func inputHandlerChanged() {
        updateInstructionLabel()
        updateInputHandlerUI()
    }
    
    // MARK: - Instruction
    
    private func updateInstructionLabel() {
        if let instruction = inputHandler.instruction {
            instructionLabel.stringValue = instruction
        } else {
            instructionLabel.stringValue = ""
        }
    }
    
    private func updateInputHandlerUI() {
        let variables = inputHandler.uiVariables
        
        variablesPanelView?.removeFromSuperview()
        variablesPanelView = nil
        
        if variables.isEmpty {
            rightPanelContainerView.isHidden = false
            return
        }
        
        let variableViews = variables.map(viewForUIVariable)
        let panelView = VariablesPanelView(frame: .zero)
        panelView.set(variableViews: variableViews)
        
        view.addSubview(panelView)
        rightPanelContainerView.isHidden = true
        
        self.variablesPanelView = panelView
    }
    
    private func viewForUIVariable(_ variable: UIVariable) -> NSView {
        
        if let doubleVariable = variable as? UIVariableDouble {
            return UIVariableViewDouble(variable: doubleVariable)
        } else {
            fatalError()
        }
    }
}

extension ViewController: SimulationViewDelegate {
    
    var inputHandlerContext: InputHandlerContext {
        return InputHandlerContext(simulation: simulation, simulationSize: simulationSize)
    }
    
    func mouseDown(at location: Vector2D) {
        inputHandler.processMouseDown(at: inputPosition(for: location), context: inputHandlerContext)
    }
    
    func mouseDragged(to location: Vector2D) {
        inputHandler.processMouseDragged(to: inputPosition(for: location), context: inputHandlerContext)
    }
    
    func mouseUp(at location: Vector2D) {
        inputHandler.processMouseUp(at: inputPosition(for: location), context: inputHandlerContext)
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
    
    private func inputPosition(for position: Vector2D) -> InputPosition {
        let gridPosition: Vector2D
        
        if GridManager.shared.gridEnabled {
            gridPosition = GridManager.shared.gridPosition(forPosition: position,
                                                           simulationSize: simulationSize)
        } else {
            gridPosition = position
        }
        
        return InputPosition(position: position,
                             gridPosition: gridPosition)
    }
}

extension ViewController: InputHandlerDelegate {
    
    func inputHandlerDidFinish(handler: InputHandler) {
        popInputHandler()
    }
}
