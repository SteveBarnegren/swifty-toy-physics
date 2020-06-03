//
//  InputHandlerVariableDouble.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 03/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

protocol UIVariable {}

class UIVariableDouble: UIVariable {
    let name: String
    let min: Double
    let max: Double
    let get: () -> Double
    let set: (Double) -> Void
    
    
    init(name: String, min: Double, max: Double, get: @escaping () -> Double, set: @escaping (Double) -> Void) {
        self.name = name
        self.min = min
        self.max = max
        self.get = get
        self.set = set
    }
}
