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
    
    func changeInYValue() -> Int {
        switch self {
        case .north:
            return 1
        case .south:
            return -1
        default:
            return 0
        }
    }
    
    func changeInXValue() -> Int {
        switch self {
        case .east:
            return 1
        case .west:
            return -1
        default:
            return 0
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
    
    var angle: Angle {
        switch self {
        case .north: Angle(degrees: 0)
        case .east: Angle(degrees: -90)
        case .west: Angle(degrees: 90)
        case .south: Angle(degrees: 180)
        }
    }
}
