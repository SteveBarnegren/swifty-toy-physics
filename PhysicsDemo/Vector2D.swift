//
//  Vector2D.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 22/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import SBSwiftUtils

typealias Vector2D = Vector2<Double>
extension Vector2D: Codable {
    
    enum CodingKeys: String, CodingKey {
        case x = "x"
        case y = "y"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = .init(try! values.decode(Double.self, forKey: CodingKeys.x),
                     try! values.decode(Double.self, forKey: CodingKeys.y))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode(self.x, forKey: CodingKeys.x)
        try! container.encode(self.y, forKey: CodingKeys.y)
    }
}

extension Vector2D {
    
    mutating func removeNanValues() {
        if self.x.isNaN {
            self.x = 0
        }
        if self.y.isNaN {
            self.y = 0
        }
    }
}

// MARK: - Conversions

extension Vector2D {
    
    init(_ nsPoint: NSPoint) {
        self.init(Double(nsPoint.x), Double(nsPoint.y))
    }
    
    var cgSize: CGSize {
        CGSize(width: self.width, height: self.height)
    }
    
    var nsPoint: NSPoint {
        NSPoint(x: self.x, y: self.y)
    }
}
