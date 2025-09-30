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
    let level: Int
    let rotation: Direction
    
    mutating func x(_ newX: Int) {
        self = .init(x: newX, y: y, level: level, rotation: rotation)
    }
    
    mutating func y(_ newY: Int) {
        self = .init(x: x, y: newY, level: level, rotation: rotation)
    }
    
    mutating func level(_ newLevel: Int) {
        self = .init(x: x, y: y, level: newLevel, rotation: rotation)
    }
    
    mutating func rotation(_ newRotation: Direction) {
        self = .init(x: x, y: y, level: level, rotation: newRotation)
    }
    
    mutating func moveBy(_ direction: Direction) {
        self = .init(x: x + direction.changeInXValue, y: y + direction.changeInYValue, level: level, rotation: rotation)
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.x != rhs.x { return false }
        if lhs.y != rhs.y { return false }
        if lhs.level != rhs.level { return false }
        return true
    }
    
    func inBounds() -> Bool {
        if(abs(x) <= Game.shared.board.border) {
            if(abs(y) <= Game.shared.board.border) {
                return true
            }
        }
        return false
    }
    
    init(x: Int, y: Int, level: Int = 0, rotation: Direction = .all.randomElement()!) {
        self.x = x
        self.y = y
        self.level = level
        self.rotation = rotation
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

enum BoardObjectType: String, Codable {
    case boardObject
    case wall
    case reinforcedWall
    case gift
    case placeholder
    case drone
    case tank
    case deadTank
    
    var name: String {
        switch self {
        case .boardObject: 
            return "Board Object"
        case .wall:
            return "Wall"
        case .reinforcedWall:
            return "Reinforced Wall"
        case .gift:
            return "Gift"
        case .placeholder:
            return "Tank Placeholder"
        case .drone:
            return "Drone"
        case .tank:
            return "Tank"
        case .deadTank:
            return "Dead Tank"
        }
    }
}

@Observable
class BoardObject: Identifiable, Equatable, Codable, Hashable { var type: BoardObjectType { .boardObject }
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var isSolid: Bool { false }
    var isRigid: Bool { false }
    
    let uuid: UUID
    
    var fuelDropped: Int
    var metalDropped: Int
    
    var appearance: Appearance?
    var coordinates: Coordinates?
    
    var health: Int
    var defense: Int
    
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
        case .reinforcedWall: return try ReinforcedWall(from: decoder)
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
            case .reinforcedWall:
                self.object = try ReinforcedWall(from: decoder)
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
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
    init(coordinates: Coordinates) {
        super.init(
            fuelDropped: 0,
            metalDropped: 0,
            appearance: Appearance(fillColor: .black, symbolColor: .black, symbol: "rectangle.fill"),
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
            appearance: Appearance(fillColor: .black, symbolColor: .black, symbol: "rectangle.fill"),
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

class ReinforcedWall: BoardObject {
    override var type: BoardObjectType { .reinforcedWall }
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
    init(coordinates: Coordinates) {
        super.init(
            fuelDropped: 0,
            metalDropped: 0,
            appearance: Appearance(fillColor: .black, symbolColor: .red, symbol: "lock.fill"),
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
            appearance: Appearance(fillColor: .black, symbolColor: .red, symbol: "lock.fill"),
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
    
    static var isSolid: Bool { false }
    static var isRigid: Bool { false }
    
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
        let doModuleMode: Bool = Int.random(in: 1...5) == 5
        self.containedModule = doModuleMode ? Module.random() : nil
        let rewardMax = doModuleMode ? 0 : 6
        let rewardMultiplier = 5
        let fuelReward = Int.random(in: 0...rewardMax) * rewardMultiplier
        let metalReward = (rewardMax * rewardMultiplier) - fuelReward
        
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
        
        var module: Module?
        if let moduleDecoder = try? container.superDecoder(forKey: .containedModule) {
            module = try? Module.decode(from: moduleDecoder)
        } else {
            module = nil
        }
        
        self.init(
            coordinates: try container.decode(Coordinates.self, forKey: .coordinates),
            fuelReward: try container.decode(Int.self, forKey: .fuelDropped),
            metalReward: try container.decode(Int.self, forKey: .metalDropped),
            containedModule: module,
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
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
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
    
    static var isSolid: Bool { false }
    static var isRigid: Bool { false }
    
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
