//
//  DisplayLink.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

class DisplayLink {
    
    static let shared = DisplayLink()
    
    var displayLink: CVDisplayLink? = nil;
    private var lastFrameTime: Double?
    
    private var observers = [(Double) -> Void]()
    
    private init() {
        setupDisplayLink()
    }
    
    private func setupDisplayLink() {
        
        func displayLinkOutputCallback( displayLink: CVDisplayLink,
                                                  _ inNow: UnsafePointer<CVTimeStamp>,
                                           _ inOutputTime: UnsafePointer<CVTimeStamp>,
                                                _ flagsIn: CVOptionFlags,
                                               _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                                     _ displayLinkContext: UnsafeMutableRawPointer? )
              -> CVReturn
              {
                  /* Get an unsafe instance of self from displayLinkContext. */
                  let unsafeSelf = Unmanaged<DisplayLink>.fromOpaque( displayLinkContext! ).takeUnretainedValue()
                  
                  unsafeSelf.tick()
                  return kCVReturnSuccess
              }
              
              CVDisplayLinkCreateWithActiveCGDisplays( &displayLink )
              CVDisplayLinkSetOutputCallback( displayLink!, displayLinkOutputCallback, Unmanaged.passUnretained(self).toOpaque() )
              CVDisplayLinkStart( displayLink! )
    }
    
    func add(observer: @escaping (Double) -> Void) {
        self.observers.append(observer)
    }

    private func tick() {
        
        guard let previous = lastFrameTime else {
            self.lastFrameTime = CACurrentMediaTime()
            return
        }
        
        let current = CACurrentMediaTime()
        let dt = current - previous
        
        //print("current time: \(current)")
        //print("dt: \(dt)")
        
        DispatchQueue.main.async { [observers] in
            for observer in observers {
                observer(dt)
            }
        }
        
        self.lastFrameTime = current
    }
}
