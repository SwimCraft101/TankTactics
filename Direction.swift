//
//  Direction.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/13/24.
//
import SwiftUI

enum Direction: Codable {
    case north
    case east
    case south
    case west
    
    static var all: [Self] {
        [.north, .south, .east, .west]
    }
    
    var changeInYValue: Int {
        switch self {
        case .north:
            return 1
        case .south:
            return -1
        default:
            return 0
        }
    }
    
    var changeInXValue: Int {
        switch self {
        case .east:
            return 1
        case .west:
            return -1
        default:
            return 0
        }
    }
    
    var opposite: Self {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .east:
            return .west
        case .west:
            return .east
        }
    }
    
    var letter: String {
        switch self {
        case .north: "N"
        case .east: "E"
        case .west: "W"
        case .south: "S"
        }
    }
    
    var name: String {
        switch self {
        case .north: "North"
        case .south: "South"
        case .east: "East"
        case .west: "West"
        }
    }
    
    func fromPerspectiveOf(_ perspective: Direction) -> RelativeDirection {
        switch (self, perspective) {
        case (.north, .north): return .up
        case (.north, .east): return .left
        case (.north, .south): return .down
        case (.north, .west): return .right
        case (.east, .north): return .right
        case (.east, .east): return .up
        case (.east, .south): return .left
        case (.east, .west): return .down
        case (.south, .north): return .down
        case (.south, .east): return .right
        case (.south, .south): return .up
        case (.south, .west): return .left
        case (.west, .north): return .left
        case (.west, .east): return .down
        case (.west, .south): return .right
        case (.west, .west): return .up
        }
    }
    
    var angle: Angle {
        switch self {
        case .north: Angle(degrees: 0)
        case .east: Angle(degrees: -90)
        case .west: Angle(degrees: 90)
        case .south: Angle(degrees: 180)
        }
    }
}

enum RelativeDirection {
    case up
    case down
    case left
    case right
    
    var arrowIcon: String {
        switch self {
        case .up: "arrow.up"
        case .right: "arrow.right"
        case .left: "arrow.left"
        case .down: "arrow.down"
        }
    }
    
    var arrowAndName: String {
        switch self {
        case .up: "􀄨 Up"
        case .right: "􀄫 Right"
        case .left: "􀄪 Left"
        case .down: "􀄩 Down"
        }
    }
}
