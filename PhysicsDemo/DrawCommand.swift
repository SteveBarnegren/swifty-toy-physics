//
//  DrawCommand.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 04/06/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation
import AppKit

enum DrawStyle {
    case stroke
    case fill
}

struct LineDrawCommand {
    let from: NSPoint
    let to: NSPoint
    var color = NSColor.white
    var strokeWidth = 1.0
}

struct CircleDrawCommand {
    let position: Vector2D
    let radius: Double
    var color = NSColor.white
    var drawStyle = DrawStyle.fill
}

struct RectDrawCommand {
    let origin: Vector2D
    let size: Vector2D
    var color = NSColor.white
    var drawStyle = DrawStyle.fill
}

enum DrawCommand {
    case line(LineDrawCommand)
    case circle(CircleDrawCommand)
    case rect(RectDrawCommand)
}
