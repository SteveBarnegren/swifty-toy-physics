//
//  GridPanelViewController.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 06/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa
import SBSwiftUtils

class GridPanelViewController: NSViewController {
    
    private let gridManager = GridManager.shared
    
    @IBOutlet private var toggleGridCheckbox: NSButton!
    @IBOutlet private var divisionsReadoutTextField: NSTextField!
    
    init() {
        super.init(nibName: "GridPanelViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationDispatcher.shared.register(observer: self, as: GridObserver.self)
        updateEnabledState()
        updateDivisionsReadout()
    }
    
    // MARK: - Actions
    
    @IBAction private func toggleGridCheckBoxPressed(sender: NSButton) {
        switch toggleGridCheckbox.state {
        case .on:
            gridManager.gridEnabled = true
        case .off:
            gridManager.gridEnabled = false
        default:
            break
        }
    }
    
    @IBAction private func increaseDivisionsButtonPressed(sender: NSButton) {
        gridManager.divisions += 1
    }
    
    @IBAction private func decreaseDivisionsButtonPressed(sender: NSButton) {
        gridManager.divisions -= 1
    }
    
    // MARK: - Update UI
    
    private func updateEnabledState() {
        
        if gridManager.gridEnabled {
            toggleGridCheckbox.state = .on
        } else {
            toggleGridCheckbox.state = .off
        }
    }
    
    private func updateDivisionsReadout() {
        divisionsReadoutTextField.stringValue = "Divisions: \(gridManager.divisions)"
    }
}

// MARK: - GridObserver

extension GridPanelViewController: GridObserver {
    
    func gridEnabledStateChanged() {
        updateEnabledState()
    }
    
    func gridDivisionsChanged() {
        updateDivisionsReadout()
    }
}
