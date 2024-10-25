//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI
import AppKit

struct Coordinates: Equatable, Hashable {
    var x: Int
    var y: Int
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
        return "c(\(x),\(y))"
    }
}

struct Appearance: Equatable, Hashable {
    var fillColor: Color
    var strokeColor: Color
    var symbolColor: Color
    var symbol: String
    
    func savedText() -> String {
        return "a(\(Int(NSColor(fillColor).cgColor.components![0] * 255)),\(Int(NSColor(fillColor).cgColor.components![1] * 255)),\(Int(NSColor(fillColor).cgColor.components![2] * 255)),\(Int(NSColor(strokeColor).cgColor.components![0] * 255)),\(Int(NSColor(strokeColor).cgColor.components![1] * 255)),\(Int(NSColor(strokeColor).cgColor.components![2] * 255)),\(Int(NSColor(symbolColor).cgColor.components![0] * 255)),\(Int(NSColor(symbolColor).cgColor.components![1] * 255)),\(Int(NSColor(symbolColor).cgColor.components![2] * 255)),\"\(symbol)\")"
    }
}

@Observable class BoardObject: Equatable, Hashable {
    static func == (lhs: BoardObject, rhs: BoardObject) -> Bool {
        return lhs.coordinates == rhs.coordinates &&
        lhs.appearance == rhs.appearance
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fuelDropped)
        hasher.combine(metalDropped)
        hasher.combine(appearance)
        hasher.combine(coordinates)
        hasher.combine(health)
        hasher.combine(defense)
    }
    
    func savedText() -> String {
        return "BoardObject(\(appearance.savedText()), \(coordinates.savedText()), \(health), \(defense), \(fuelDropped), \(metalDropped))\n"
    }
    
    var fuelDropped: Int = 0
    var metalDropped: Int = 0
    
    var appearance: Appearance
    var coordinates: Coordinates
    var health: Int = 1
    var defense: Int = 0
    
    func tick() {
        if health <= 0 {
            board.objects.removeAll(where: {
                $0 == self
            })
            if(fuelDropped > 0 || metalDropped > 0) {
                board.objects.append(Gift(coordinates: self.coordinates, fuelReward: fuelDropped, metalReward: metalDropped))
            }
        }
    }
    
    func move(_ direction: [Direction]) {
        for step in direction {
            self.coordinates.x += step.changeInXValue()
            self.coordinates.y += step.changeInYValue()
        }
    }
    
    init(appearance: Appearance, coordinates: Coordinates) {
        self.appearance = appearance
        self.coordinates = coordinates
    }
    
    init(_ appearance: Appearance, _ coordinates: Coordinates, _ health: Int, _ defense: Int, _ fuelDropped: Int, _ metalDropped: Int) {
        self.appearance = appearance
        self.coordinates = coordinates
        self.health = health
        self.defense = defense
        self.fuelDropped = fuelDropped
        self.metalDropped = metalDropped
    }
}

class Wall: BoardObject {
    init(_ coordinates: Coordinates) {
        super.init(appearance: Appearance(fillColor: .black, strokeColor: .black, symbolColor: .black, symbol: "rectangle.fill"), coordinates: coordinates)
    }
    
    init(coordinates: Coordinates) {
        super.init(appearance: Appearance(fillColor: .black, strokeColor: .black, symbolColor: .black, symbol: "rectangle.fill"), coordinates: coordinates)
    }
    
    override func savedText() -> String {
        return "w(\(coordinates.x),\(coordinates.y)),"
    }
}

class Gift: BoardObject {
    init(coordinates: Coordinates, fuelReward: Int, metalReward: Int) {
        if fuelReward == 0 {
            super.init(appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "square.grid.2x2"), coordinates: coordinates)
        } else if metalReward == 0 {
            super.init(appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "fuelpump"), coordinates: coordinates)
        } else {
            super.init(appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift"), coordinates: coordinates)
        }
        fuelDropped = fuelReward
        metalDropped = metalReward
    }
    override func savedText() -> String {
        return "g(\(self.coordinates.x),\(self.coordinates.y),\(self.fuelDropped),\(self.metalDropped)),"
    }
}

class TankPlaceholder: BoardObject {
    init(coordinates: Coordinates) {
        super.init(appearance: Appearance(fillColor: .gray, strokeColor: .black, symbolColor: .black, symbol: "questionmark.square.dashed"), coordinates: coordinates)
    }
    override func savedText() -> String {
        "TankPlaceholder(coordinates: \(coordinates.savedText()))"
    }
}
