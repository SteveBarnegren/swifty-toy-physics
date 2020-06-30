//
//  GridManager.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 06/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit
import SBSwiftUtils

protocol GridObserver {
    func gridEnabledStateChanged()
    func gridDivisionsChanged()
}

class GridManager {
    
    static let shared = GridManager()
    
    var gridEnabled = false {
        didSet {
            if oldValue != self.gridEnabled {
                NotificationDispatcher.shared.notify(GridObserver.self) {
                    $0.gridEnabledStateChanged()
                }
            }
        }
    }
    
    var divisions = 10 {
        didSet {
            let newValue = self.divisions.constrained(min: 2)
            self.divisions = newValue
            
            if oldValue != newValue {
                NotificationDispatcher.shared.notify(GridObserver.self) {
                    $0.gridDivisionsChanged()
                }
            }
        }
    }
    
    func gridPosition(forPosition inputPosition: Vector2D, simulationSize simSize: Vector2D) -> Vector2D {
        
        let stepSize = self.stepSize(forSimulationSize: simSize)
        
        let y = (inputPosition.y / stepSize).rounded(.toNearestOrEven) * stepSize
        
        let xOffset = modf((simSize.width/2) / stepSize).1 * stepSize
        let x = ((inputPosition.x - xOffset) / stepSize).rounded(.toNearestOrEven) * stepSize + xOffset
        
        return Vector2D(x, y)
    }
    
    // MARK: - Grid Helpers
    
    private func stepSize(forSimulationSize simSize: Vector2D) -> Double {
        simSize.height / Double(divisions)
    }
}

// MARK: - Drawing

extension GridManager {
    
    func drawCommands(forSimulationSize simSize: Vector2D) -> [DrawCommand] {
        
        if gridEnabled == false {
            return []
        }
        
        let color = NSColor.lightGray.withAlphaComponent(0.35)
        
        let stepSize = self.stepSize(forSimulationSize: simSize)
        var drawCommands = [DrawCommand]()
        
        // Horizontal lines
        for i in 1..<divisions {
            let y = Double(i) * stepSize
            let line = LineDrawCommand(from: Vector2D(0, y).nsPoint,
                                       to: Vector2D(simSize.width, y).nsPoint,
                                       color: color,
                                       strokeWidth: 1)
            drawCommands.append(.line(line))
        }
        
        // Vertical lines
        let midX = simSize.width/2
        var xPositions = [Double]()
        xPositions.append(midX)
        stride(from: midX + stepSize, to: simSize.width, by: stepSize).forEach { xPositions.append($0) }
        stride(from: midX - stepSize, to: 0, by: -stepSize).forEach { xPositions.append($0) }

        for xPos in xPositions {
            let line = LineDrawCommand(from: Vector2D(xPos, 0).nsPoint,
                                       to: Vector2D(xPos, simSize.height).nsPoint,
                                       color: color,
                                       strokeWidth: 1)
            drawCommands.append(.line(line))
        }
        
        
        return drawCommands
    }
}
