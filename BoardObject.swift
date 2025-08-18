//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI

struct Coordinates: Equatable, Codable { //MARK: Add rotation support
    var x: Int
    var y: Int
    var level: Int
    var rotation: CardinalDirection
    
    enum CardinalDirection: Codable {
        case north
        case east
        case south
        case west
        
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
    
    func viewOffset(right: Int, up: Int) -> Coordinates {
        switch rotation {
        case .north:
            return Coordinates(x: x + right, y: y + up, level: level)
        case .east:
            return Coordinates(x: x + up, y: y - right, level: level)
        case .south:
            return Coordinates(x: x - right, y: y - up, level: level)
        case .west:
            return Coordinates(x: x - up, y: y + right, level: level)
        }
    }
    
    func distanceTo(_ other: Coordinates) -> Int {
        let deltax = abs(other.x - x)
        let deltay = abs(other.y - y)
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
    
    init(x: Int, y: Int, level: Int = 0, rotation: CardinalDirection = .north) {
        self.x = x
        self.y = y
        self.level = level
        self.rotation = rotation
    }
}

struct Appearance: Equatable, Codable {
    var fillColor: Color
    var strokeColor: Color?
    var symbolColor: Color?
    var symbol: String
}

enum BoardObjectType: String, Codable {
    case boardObject
    case wall
    case gift
    case placeholder
    case drone
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
    
    let uuid: UUID
    
    var fuelDropped: Int
    var metalDropped: Int
    
    var appearance: Appearance?
    var coordinates: Coordinates?
    
    var health: Int
    var defense: Int
    
    //MARK: add solid/rigid collision system
    
    enum CodingKeys: String, CodingKey {
        case type
        case uuid
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
        case .drone: return try Drone(from: decoder)
        case .tank: return try Tank(from: decoder)
        case .deadTank: return try DeadTank(from: decoder)
        case .boardObject: return try BoardObject(from: decoder)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.fuelDropped = try container.decode(Int.self, forKey: .fuelDropped)
        self.metalDropped = try container.decode(Int.self, forKey: .metalDropped)
        self.health = try container.decode(Int.self, forKey: .health)
        self.defense = try container.decode(Int.self, forKey: .defense)
        self.appearance = try container.decode(Appearance?.self, forKey: .appearance)
        self.coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(fuelDropped, forKey: .fuelDropped)
        try container.encode(metalDropped, forKey: .metalDropped)
        try container.encode(health, forKey: .health)
        try container.encode(defense, forKey: .defense)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(coordinates, forKey: .coordinates)
    }
    
    init(fuelDropped: Int, metalDropped: Int, appearance: Appearance?, coordinates: Coordinates? = nil, health: Int, defense: Int, uuid: UUID) {
        self.uuid = uuid
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
            case .drone:
                self.object = try Drone(from: decoder)
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
            defense: 0,
            uuid: UUID()
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case uuid
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
            defense: 0,
            uuid: try container.decode(UUID.self, forKey: .uuid)
        )
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(coordinates, forKey: .coordinates)
    }
}

class Gift: BoardObject {
    override var type: BoardObjectType { .gift }
    let containedModule: Module?
    
    init(coordinates: Coordinates, fuelReward: Int, metalReward: Int, containedModule: Module?, uuid: UUID?) {
        self.containedModule = containedModule
        super.init(
            fuelDropped: fuelReward,
            metalDropped: metalReward,
            appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift"),
            coordinates: coordinates,
            health: 1,
            defense: 0,
            uuid: uuid ?? UUID()
        )
        updateAppearance(fuelReward: fuelReward, metalReward: metalReward)
    }
    
    init(coordinates: Coordinates) {
        let doModuleMode: Bool = Int.random(in: 1...10) == 10
        self.containedModule = doModuleMode ? Module.random() : nil
        let rewardMax = doModuleMode ? 0 : 30
        let fuelReward = Int.random(in: 0...rewardMax)
        let metalReward = rewardMax - fuelReward
        
        super.init(
            fuelDropped: fuelReward,
            metalDropped: metalReward,
            appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift"),
            coordinates: coordinates,
            health: 1,
            defense: 0,
            uuid: UUID()
        )
        updateAppearance(fuelReward: fuelReward, metalReward: metalReward)
    }
    
    private func updateAppearance(fuelReward: Int, metalReward: Int) {
        if fuelReward + metalReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "square.on.square.dashed")
        } else if fuelReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "square.grid.2x2")
        } else if metalReward == 0 {
            appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "fuelpump")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case uuid
        case coordinates
        case fuelDropped
        case metalDropped
        case containedModule
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            coordinates: try container.decode(Coordinates.self, forKey: .coordinates),
            fuelReward: try container.decode(Int.self, forKey: .fuelDropped),
            metalReward: try container.decode(Int.self, forKey: .metalDropped),
            containedModule: try container.decode(Module.self, forKey: .containedModule),
            uuid: try container.decode(UUID.self, forKey: .uuid)
        )
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(fuelDropped, forKey: .fuelDropped)
        try container.encode(metalDropped, forKey: .metalDropped)
        try container.encode(containedModule, forKey: .containedModule)
    }
}

class Placeholder: BoardObject {
    override var type: BoardObjectType { .placeholder }
    
    init(coordinates: Coordinates, uuid: UUID?) {
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
            defense: 10000,
            uuid: uuid ?? UUID()
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case uuid
        case coordinates
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(coordinates: try container.decode(Coordinates.self, forKey: .coordinates), uuid: try container.decode(UUID.self, forKey: .uuid))
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(coordinates, forKey: .coordinates)
    }
}

class Drone: BoardObject {
    override var type: BoardObjectType { .drone }
    
    init(coordinates: Coordinates, uuid: UUID?) {
        super.init(
            fuelDropped: 0,
            metalDropped: 0,
            appearance: nil,
            coordinates: coordinates,
            health: 10000,
            defense: 10000,
            uuid: uuid ?? UUID()
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case uuid
        case coordinates
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(coordinates: try container.decode(Coordinates.self, forKey: .coordinates), uuid: try container.decode(UUID.self, forKey: .uuid))
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(coordinates, forKey: .coordinates)
    }
}
