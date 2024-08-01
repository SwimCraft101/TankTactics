//
//  Direction.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/13/24.
//

enum Direction {
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
}
