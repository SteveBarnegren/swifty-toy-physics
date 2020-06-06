//
//  InputHandlerSwitch.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 23/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

class InputHandlerSwitch: InputHandler {
    
    private let handlers: [InputHandler]
    private let currentIndex: () -> Int
    
    init(handlers: [InputHandler], currentIndex: @escaping () -> Int) {
        self.handlers = handlers
        self.currentIndex = currentIndex
    }
    
    private var currentHandler: InputHandler {
        return handlers[currentIndex()]
    }
    
    override func mouseDown(at position: InputPosition, context: InputHandlerContext) {
        currentHandler.mouseDown(at: position, context: context)
    }
    
    override func mouseDragged(to position: InputPosition, context: InputHandlerContext) {
        currentHandler.mouseDragged(to: position, context: context)
    }
    
    override func mouseUp(at position: InputPosition, context: InputHandlerContext) {
        currentHandler.mouseUp(at: position, context: context)
    }
}
