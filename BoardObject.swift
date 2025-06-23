//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI
import AppKit

struct Coordinates: Equatable {
    var x: Int
    var y: Int
    var level: Int
    let border = 12
    
    func distanceTo(_ other: Coordinates) -> Int {
        var deltax = abs(other.x - x)
        var deltay = abs(other.y - y)
        deltax *= deltax
        deltay *= deltay
        return Int(sqrt(Double(deltax + deltay)) + 0.5)
    }
    
    func inBounds() -> Bool {
        if(abs(x) <= border) {
            if(abs(y) <= border) {
                return true
            }
        }
        return false
    }
    
    func savedText() -> String {
        return "c(\(x),\(y),\(level))"
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        self.level = 0
    }
    
    init(x: Int, y: Int, level: Int) {
        self.x = x
        self.y = y
        self.level = level
    }
}

struct Appearance: Equatable {
    var fillColor: Color
    var strokeColor: Color
    var symbolColor: Color
    var symbol: String
    
    func savedText() -> String {
        return "a(\(Int(NSColor(fillColor).cgColor.components![0] * 255)),\(Int(NSColor(fillColor).cgColor.components![1] * 255)),\(Int(NSColor(fillColor).cgColor.components![2] * 255)),\(Int(NSColor(strokeColor).cgColor.components![0] * 255)),\(Int(NSColor(strokeColor).cgColor.components![1] * 255)),\(Int(NSColor(strokeColor).cgColor.components![2] * 255)),\(Int(NSColor(symbolColor).cgColor.components![0] * 255)),\(Int(NSColor(symbolColor).cgColor.components![1] * 255)),\(Int(NSColor(symbolColor).cgColor.components![2] * 255)),\"\(symbol)\")"
    }
}

struct AnyBoardObject: Equatable {
    private let _base: any BoardObject
    private let _isEqual: (AnyBoardObject) -> Bool

    init<T: BoardObject & Equatable>(_ base: T) {
        self._base = base
        self._isEqual = { other in
            guard let otherBase = other._base as? T else { return false }
            return base == otherBase
        }
    }

    static func == (lhs: AnyBoardObject, rhs: AnyBoardObject) -> Bool {
        return lhs._isEqual(rhs)
    }

    var base: any BoardObject {
        return _base
    }
}

protocol BoardObject: AnyObject, Identifiable, Equatable {
    var fuelDropped: Int { get set }
    var metalDropped: Int { get set }
    
    var appearance: Appearance { get }
    var coordinates: Coordinates? { get set }
    
    var health: Int { get set }
    var defense: Int { get set }
}

extension BoardObject {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

class Wall: BoardObject {
    var fuelDropped: Int = 0
    var metalDropped: Int = 0
    
    let appearance: Appearance = Appearance(fillColor: .black, strokeColor: .black, symbolColor: .black, symbol: "rectangle.fill")
    var coordinates: Coordinates?
    
    var health: Int = 1
    var defense: Int = 0
    
    var id: UUID = UUID()
    
    init(coordinates: Coordinates) {
        self.coordinates = coordinates
    }
}

class Gift: BoardObject {
    static func == (lhs: Gift, rhs: Gift) -> Bool {
        if lhs.fuelDropped != rhs.fuelDropped { return false }
        if lhs.metalDropped != rhs.metalDropped { return false }
        if lhs.appearance != rhs.appearance { return false }
        if lhs.coordinates != rhs.coordinates { return false }
        if lhs.health != rhs.health { return false }
        if lhs.defense != rhs.defense { return false }
        return true
    }
    
    var fuelDropped: Int
    var metalDropped: Int
    
    let appearance: Appearance
    var coordinates: Coordinates?
    
    var health: Int = 1
    var defense: Int = 0
    
    init(coordinates: Coordinates, fuelReward: Int, metalReward: Int) {
        if fuelReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "square.grid.2x2")
        } else if metalReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "fuelpump")
        } else {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift")
        }
        self.fuelDropped = fuelReward
        self.metalDropped = metalReward
        self.coordinates = coordinates
    }
}

class Placeholder: BoardObject {
    static func == (lhs: Placeholder, rhs: Placeholder) -> Bool {
        if lhs.fuelDropped != rhs.fuelDropped { return false }
        if lhs.metalDropped != rhs.metalDropped { return false }
        if lhs.appearance != rhs.appearance { return false }
        if lhs.coordinates != rhs.coordinates { return false }
        if lhs.health != rhs.health { return false }
        if lhs.defense != rhs.defense { return false }
        return true
    }
    
    var fuelDropped: Int = 0
    var metalDropped: Int = 0
    
    let appearance = Appearance(fillColor: .gray, strokeColor: .black, symbolColor: .black, symbol: "questionmark.square.dashed")
    var coordinates: Coordinates?
    
    var health: Int = 1
    var defense: Int = 0
    
    init(coordinates: Coordinates) {
        self.coordinates = coordinates
    }
}
