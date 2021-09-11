//
//  UIVariableViewDouble.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 03/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class UIVariableViewDouble: NSView {
    
    private let variable: UIVariableDouble
    private var titleLabel: NSTextField!
    private var slider: NSSlider!
    private var readoutLabel: NSTextField!

    // MARK: - Init
    
    init(variable: UIVariableDouble) {
        self.variable = variable
        super.init(frame: .zero)

        // Title
        titleLabel = NSTextField(labelWithString: variable.name)
        titleLabel.alignment = .center
        addSubview(titleLabel)
        titleLabel.pinToSuperviewLeft(0)
        titleLabel.pinToSuperviewRight(0)
        titleLabel.pinToSuperviewTop(0)
        
        // Slider
        slider = NSSlider(value: variable.get(),
                          minValue: variable.min,
                          maxValue: variable.max,
                          target: self,
                          action: #selector(sliderValueChanged))
        addSubview(slider)
        slider.pinBelowView(titleLabel, separation: 8)
        slider.pinToSuperviewLeft(0)
        slider.pinToSuperviewRight(0)
        slider.pinWidth(500, priority: UILayoutPriority(251))
        
        // Readout
        readoutLabel = NSTextField(labelWithString: "")
        readoutLabel.alignment = .center
        addSubview(readoutLabel)
        readoutLabel.pinBelowView(slider)
        readoutLabel.pinToSuperviewLeft(0)
        readoutLabel.pinToSuperviewRight(0)
        readoutLabel.pinToSuperviewBottom(0)
        
        updateReadoutLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sliderValueChanged(sender: NSSlider) {
        variable.set(sender.doubleValue)
        updateReadoutLabel()
    }
    
    private func updateReadoutLabel() {
        readoutLabel.stringValue = String(format: "%.2f", variable.get())
    }
}
