//
//  TimeStepper.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 29/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

private let loggingEnabled = true
private func log(steps: [Double], interpolate: Double = 0) {
    if loggingEnabled {
        var output = "[" + steps.map { String(format: "%.4f", $0) }.joined(separator: ", ") + "]"
        if interpolate != 0 {
            output += " Interpolate: \(String(format: "%.4f", interpolate))"
        }
        print(output)
    }
}

protocol TimeStepper {
    func consume(time: Double)
    func stepSimulation(updateSim: (Double) -> Void)
    var renderFrameInterpolationTime: Double { get }
}

extension TimeStepper {
    var renderFrameInterpolationTime: Double { return 0 }
}

class TimeStepperVariable: TimeStepper {

    private var remainingTime = 0.0

    func consume(time: Double) {
        remainingTime += time
    }
    
    func stepSimulation(updateSim: (Double) -> Void) {
        log(steps: [remainingTime])
        updateSim(remainingTime)
        remainingTime = 0
    }
}

class TimeStepperSemiFixed: TimeStepper {
    
    private var remainingTime = 0.0
    var stepSize = 1.0 / 60.0
    
    func consume(time: Double) {
        remainingTime += time
    }
    
    func stepSimulation(updateSim: (Double) -> Void) {
        
        var recordedSteps = [Double]()
             
        while remainingTime >= stepSize {
            updateSim(stepSize)
            recordedSteps.append(stepSize)
            remainingTime -= stepSize
        }
        
        if remainingTime > 0 {
            updateSim(remainingTime)
            recordedSteps.append(remainingTime)
            remainingTime = 0
        }
        
        log(steps: recordedSteps)
    }
}

class TimeStepperFixed: TimeStepper {

    private var remainingTime = 0.0
    var stepSize = 1.0 / 240

    func consume(time: Double) {
        remainingTime += time
    }
    
    func stepSimulation(updateSim: (Double) -> Void) {
        
        var recordedSteps = [Double]()
        
        while remainingTime >= stepSize {
            updateSim(stepSize)
            recordedSteps.append(stepSize)
            remainingTime -= stepSize
        }
        
        log(steps: recordedSteps, interpolate: remainingTime)
    }
    
    var renderFrameInterpolationTime: Double {
        return remainingTime
    }
}
