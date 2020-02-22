//
//  Numeric+Constrained.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

public extension Numeric where Self: Comparable {
    
    func constrained(min minimumValue: Self) -> Self {
        return Swift.max(self, minimumValue)
    }
    
    func constrained(max maximumValue: Self) -> Self {
        return Swift.min(self, maximumValue)
    }
    
    func constrained(min minimumValue: Self, max maximumValue: Self) -> Self {
        return  Swift.max(Swift.min(self, maximumValue), minimumValue)
    }
}

