//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI

struct Coordinates: Equatable, Codable {
    var x: Int
    var y: Int
    var level: Int
    
    func distanceTo(_ other: Coordinates) -> Int {
        var deltax = abs(other.x - x)
        var deltay = abs(other.y - y)
        return Int(deltax + deltay)
    }
    
    func inBounds() -> Bool {
        if(abs(x) <= game.board.border) {
            if(abs(y) <= game.board.border) {
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

struct Appearance: Equatable, Codable {
    var fillColor: Color
    var strokeColor: Color
    var symbolColor: Color
    var symbol: String
    
    func savedText() -> String {
        return "a(\(Int(NSColor(fillColor).cgColor.components![0] * 255)),\(Int(NSColor(fillColor).cgColor.components![1] * 255)),\(Int(NSColor(fillColor).cgColor.components![2] * 255)),\(Int(NSColor(strokeColor).cgColor.components![0] * 255)),\(Int(NSColor(strokeColor).cgColor.components![1] * 255)),\(Int(NSColor(strokeColor).cgColor.components![2] * 255)),\(Int(NSColor(symbolColor).cgColor.components![0] * 255)),\(Int(NSColor(symbolColor).cgColor.components![1] * 255)),\(Int(NSColor(symbolColor).cgColor.components![2] * 255)),\"\(symbol)\")"
    }
}

enum BoardObjectType: String, Codable {
    case boardObject
    case wall
    case gift
    case placeholder
    case tank
    case deadTank
}

class BoardObject: Identifiable, Equatable, Codable { var type: BoardObjectType { .boardObject }
    static func == (lhs: BoardObject, rhs: BoardObject) -> Bool {
        if lhs.coordinates != rhs.coordinates {
            return false
        }
        if lhs.appearance != rhs.appearance {
            return false
        }
        if lhs.health != rhs.health {
            return false
        }
        if lhs.defense != rhs.defense {
            return false
        }
        if lhs.fuelDropped != rhs.fuelDropped {
            return false
        }
        if lhs.metalDropped != rhs.metalDropped {
            return false
        }
        return true
    }
    
    var fuelDropped: Int
    var metalDropped: Int
    
    var appearance: Appearance
    var coordinates: Coordinates?
    
    var health: Int
    var defense: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case fuelDropped
        case metalDropped
        case appearance
        case coordinates
        case health
        case defense
    }
    
    static func decode(from decoder: Decoder) throws -> BoardObject {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BoardObjectType.self, forKey: .type)

        switch type {
        case .wall: return try Wall(from: decoder)
        case .gift: return try Gift(from: decoder)
        case .placeholder: return try Placeholder(from: decoder)
        case .tank: return try Tank(from: decoder)
        case .deadTank: return try DeadTank(from: decoder)
        case .boardObject: return try BoardObject(from: decoder)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fuelDropped = try container.decode(Int.self, forKey: .fuelDropped)
        self.metalDropped = try container.decode(Int.self, forKey: .metalDropped)
        self.health = try container.decode(Int.self, forKey: .health)
        self.defense = try container.decode(Int.self, forKey: .defense)
        self.appearance = try container.decode(Appearance.self, forKey: .appearance)
        self.coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(fuelDropped, forKey: .fuelDropped)
        try container.encode(metalDropped, forKey: .metalDropped)
        try container.encode(health, forKey: .health)
        try container.encode(defense, forKey: .defense)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(coordinates, forKey: .coordinates)
    }
    
    init(fuelDropped: Int, metalDropped: Int, appearance: Appearance, coordinates: Coordinates? = nil, health: Int, defense: Int) {
        self.fuelDropped = fuelDropped
        self.metalDropped = metalDropped
        self.appearance = appearance
        self.coordinates = coordinates
        self.health = health
        self.defense = defense
    }
}

extension BoardObject {
    static func encodeArray(_ objects: [BoardObject]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(objects)
    }
    
    static func decodeArray(from data: Data) throws -> [BoardObject] {
        let decoder = JSONDecoder()
        let rawObjects = try decoder.decode([PolymorphicContainer].self, from: data)
        return rawObjects.map { $0.object }
    }
    
    // Private helper for decoding
    private struct PolymorphicContainer: Decodable {
        let object: BoardObject
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: BoardObject.CodingKeys.self)
            let type = try container.decode(BoardObjectType.self, forKey: .type)
            
            switch type {
            case .boardObject:
                self.object = try BoardObject(from: decoder)
            case .wall:
                self.object = try Wall(from: decoder)
            case .gift:
                self.object = try Gift(from: decoder)
            case .placeholder:
                self.object = try Placeholder(from: decoder)
            case .tank:
                self.object = try Tank(from: decoder)
            case .deadTank:
                self.object = try DeadTank(from: decoder)
            }
        }
    }
}

class Wall: BoardObject {
    override var type: BoardObjectType { .wall }
    
    init(coordinates: Coordinates) {
        super.init(
            fuelDropped: 0,
            metalDropped: 0,
            appearance: Appearance(fillColor: .black, strokeColor: .black, symbolColor: .black, symbol: "rectangle.fill"),
            coordinates: coordinates,
            health: 1,
            defense: 0
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        super.init(
            fuelDropped: 0,
            metalDropped: 0,
            appearance: Appearance(fillColor: .black, strokeColor: .black, symbolColor: .black, symbol: "rectangle.fill"),
            coordinates: try container.decode(Coordinates.self, forKey: .coordinates),
            health: 1,
            defense: 0
        )
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(coordinates, forKey: .coordinates)
    }
}

class Gift: BoardObject {
    override var type: BoardObjectType { .gift }
    
    init(coordinates: Coordinates, fuelReward: Int, metalReward: Int) {
        super.init(
            fuelDropped: fuelReward,
            metalDropped: metalReward,
            appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift"),
            coordinates: coordinates,
            health: 1,
            defense: 0
        )
        updateAppearance(fuelReward: fuelReward, metalReward: metalReward)
    }
    
    init(coordinates: Coordinates) {
        let rewardMax = 20
        let fuelReward = Int.random(in: 1...rewardMax)
        let metalReward = rewardMax - fuelReward
        
        super.init(
            fuelDropped: fuelReward,
            metalDropped: metalReward,
            appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift"),
            coordinates: coordinates,
            health: 1,
            defense: 0
        )
        updateAppearance(fuelReward: fuelReward, metalReward: metalReward)
    }
    
    private func updateAppearance(fuelReward: Int, metalReward: Int) {
        if fuelReward + metalReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "exclamationmark.triangle")
        } else if fuelReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "square.grid.2x2")
        } else if metalReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "fuelpump")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
        case fuelDropped
        case metalDropped
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            coordinates: try container.decode(Coordinates.self, forKey: .coordinates),
            fuelReward: try container.decode(Int.self, forKey: .fuelDropped),
            metalReward: try container.decode(Int.self, forKey: .metalDropped)
        )
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(fuelDropped, forKey: .fuelDropped)
        try container.encode(metalDropped, forKey: .metalDropped)
    }
}

class Placeholder: BoardObject {
    override var type: BoardObjectType { .placeholder }
    
    init(coordinates: Coordinates) {
        super.init(
            fuelDropped: 0,
            metalDropped: 0,
            appearance: Appearance(
                fillColor: .gray,
                strokeColor: .black,
                symbolColor: .black,
                symbol: "questionmark.square.dashed"
            ),
            coordinates: coordinates,
            health: 10000,
            defense: 10000
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(coordinates: try container.decode(Coordinates.self, forKey: .coordinates))
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(coordinates, forKey: .coordinates)
    }
}
