//
//  MainView.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 23/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

protocol KeyHandler: class {
    func keyDown(with event: NSEvent)
    func flagsChanged(with event: NSEvent)
    func cancelOperation(_ sender: Any?)
}

extension NSViewController: KeyHandler {}

class MainView: NSView {
    
    weak var keyHandler: KeyHandler?
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        keyHandler?.keyDown(with: event)
    }
    
    override func flagsChanged(with event: NSEvent) {
        keyHandler?.flagsChanged(with: event)
    }
}
