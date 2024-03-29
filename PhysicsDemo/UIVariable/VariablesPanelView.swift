//
//  VariablesPanelView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 03/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout
import SBSwiftUtils

class VariablesPanelView: NSView {
    
    private var variableViews = [NSView]()
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(variableViews newVariableViews: [NSView]) {
        
        variableViews.forEach { $0.removeFromSuperview() }
        variableViews.removeAll()
        
        var lastView: NSView?
        
        for newView in newVariableViews {
            addSubview(newView)
            
            if let last = lastView {
                newView.pinBelowView(last)
            } else {
                newView.pinToSuperviewTop(0)
            }
            
            newView.pinToSuperviewLeft(0)
            newView.pinToSuperviewRight(0)
            lastView = newView
        }
        
        variableViews = newVariableViews
    }
}
