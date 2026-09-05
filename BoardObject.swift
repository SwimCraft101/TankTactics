//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI

struct Coordinates: Equatable, Codable {
    let x: Int
    let y: Int
    let rotation: Direction
    
    mutating func x(_ newX: Int) {
        self = .init(x: newX, y: y, rotation: rotation)
    }
    
    mutating func y(_ newY: Int) {
        self = .init(x: x, y: newY, rotation: rotation)
    }
    
    mutating func rotation(_ newRotation: Direction) {
        self = .init(x: x, y: y, rotation: newRotation)
    }
    
    mutating func moveBy(_ direction: Direction) {
        self = .init(x: x + direction.changeInXValue, y: y + direction.changeInYValue, rotation: rotation)
    }
    
    func viewOffset(right: Int, up: Int) -> Coordinates {
        switch rotation {
        case .north:
            return Coordinates(x: x + right, y: y + up)
        case .east:
            return Coordinates(x: x + up, y: y - right)
        case .south:
            return Coordinates(x: x - right, y: y - up)
        case .west:
            return Coordinates(x: x - up, y: y + right)
        }
    }
    
    func distanceTo(_ other: Coordinates) -> Int {
        let deltax = abs(other.x - x)
        let deltay = abs(other.y - y)
        return Int(deltax + deltay)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.x != rhs.x { return false }
        if lhs.y != rhs.y { return false }
        return true
    }
    
    init(x: Int, y: Int, rotation: Direction = .all.randomElement()!) {
        self.x = x
        self.y = y
        self.rotation = rotation
    }
    
    var description: String {
        return "X: \(x), Y: \(y)"
    }
}

struct Appearance: Equatable, Codable {
    let fillColor: Color
    let strokeColor: Color?
    let symbolColor: Color?
    let symbol: String
    
    mutating func fillColor(_ newFillColor: Color) {
        self = .init(fillColor: newFillColor, strokeColor: strokeColor, symbolColor: symbolColor, symbol: symbol)
    }
    
    mutating func strokeColor(_ newStrokeColor: Color?) {
        self = .init(fillColor: fillColor, strokeColor: newStrokeColor, symbolColor: symbolColor, symbol: symbol)
    }
    
    mutating func symbolColor(_ newSymbolColor: Color?) {
        self = .init(fillColor: fillColor, strokeColor: strokeColor, symbolColor: newSymbolColor, symbol: symbol)
    }
    
    mutating func symbol(_ newSymbol: String) {
        self = .init(fillColor: fillColor, strokeColor: strokeColor, symbolColor: symbolColor, symbol: newSymbol)
    }
    
    init(fillColor: Color, strokeColor: Color? = nil, symbolColor: Color? = nil, symbol: String) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.symbolColor = symbolColor
        self.symbol = symbol
    }
}

enum CollisionType: Codable {
    case solid
    case permeable
    case incorporeal
    case magic
    
    var canBeDrivenThrough: Bool {
        switch self {
        case .solid, .magic:
            return true
        default:
            return false
        }
    }
    
    var canBeFiredThrough: Bool {
        switch self {
        case .solid, .permeable:
            return true
        default:
            return false
        }
    }
}

enum DamageType: Codable {
    case tankWeapon(killerName: String); #warning("Once modules are finalized split this into different types")
    case tankCollision(colliderName: String)
    case wallCollision
    case smite //intentionally anonymous
    case outerWall
    
    func damageMessage(for damageAmount: Int) -> String {
        switch self {
            case .tankWeapon (let playerName):
                return "\(playerName) shot you, dealing \(damageAmount)􀲗."
            case .tankCollision (let playerName):
                return "\(playerName) crashed into you, dealing \(damageAmount)􀲗."
            case .wallCollision:
                return "You crashed into a wall, taking \(damageAmount)􀲗."
            case .smite:
                return "You were smitten for \(damageAmount)􀲗."
            case .outerWall:
                return "The Outer Wall hit you, dealing \(damageAmount)􀲗."
        }
    }
    
    func deathMessage(for nameOfDeceased: String) -> String {
        switch self {
            case .tankWeapon (let playerName):
                return "\(nameOfDeceased) was killed by \(playerName)."
            case .tankCollision (let playerName):
                return "\(nameOfDeceased) was killed in a crash with \(playerName)."
            case .wallCollision:
                return "\(nameOfDeceased) got into a fight against a Wall and lost."
            case .smite:
                return "\(nameOfDeceased) was smitten to death."
            case .outerWall:
                return "\(nameOfDeceased) should have escaped the Outer Wall."
        }
    }
}

protocol BoardObject: Identifiable, Codable {
    static var collisionType: CollisionType { get }
    
    var uuid: UUID { get }
    
    var metalDropped: Int { get }
    
    var appearance: Appearance { get }
    var coordinates: Coordinates { get set }
    
    var health: Int { get set }
    
    
}

class Wall: BoardObject {
    static let collisionType: CollisionType = .solid
    
    let uuid: UUID
    
    var metalDropped: Int { 0 }
    
    let appearance: Appearance
    
    var coordinates: Coordinates
    
    var health: Int
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
    init(coordinates: Coordinates) {
        self.coordinates = coordinates
        self.health = 1 ;#warning("Should Walls have 1 health?")
        self.appearance = Appearance(fillColor: .black, symbol: "")
        self.uuid = UUID()
    }
}

class OreDeposit: BoardObject {
    static let collisionType: CollisionType = .solid
    
    let uuid: UUID
    
    var metalDropped: Int { Int.random(in: 15...30) } ;#warning("Rebalance metal amount")
    
    let appearance: Appearance
    
    var coordinates: Coordinates
    
    var health: Int
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
    init(coordinates: Coordinates) {
        self.coordinates = coordinates
        self.health = 25 ;#warning("Should Ores have 25 health?")
        self.appearance = Appearance(fillColor: .white, symbol: "mountain.2")
        self.uuid = UUID()
    }
}

#Preview {
    BasicTileView(appearance: Appearance(fillColor: .white, symbol: "mountain.2"), accessibilitySettings: AccessibilitySettings())
}
