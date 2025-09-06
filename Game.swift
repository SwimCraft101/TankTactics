//
//  Game.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import SwiftUICore
#if DEBUG
let playerDemographics = PlayerDemographics(firstName: "Example", lastName: "Tank", deliveryBuilding: "Newberrry Centre", deliveryType: "Carrier Pigion", deliveryNumber: "Hawkey", virtualDelivery: nil, accessibilitySettings: AccessibilitySettings(), kills: 0)
let uuid = UUID()
let tank = Tank(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .black, symbol: "xmark.triangle.circle.square"), coordinates: Coordinates(x: 0, y: 0), playerDemographics: PlayerDemographics(firstName: "first", lastName: "last", deliveryBuilding: "building", deliveryType: "type", deliveryNumber: "num", virtualDelivery: "email", accessibilitySettings: AccessibilitySettings(highContrast: false, colorblind: false, largeText: false), kills: 0), fuel: 20, metal: 30, health: 84, defense: 2, movementCost: 10, movementRange: 2, gunRange: 2, gunDamage: 10, gunCost: 9, highDetailSightRange: 3, lowDetailSightRange: 4, radarRange: 5, modules: [
    ConduitModule(tankId: uuid),
    ConduitModule(tankId: uuid),
    RadarModule(tankId: uuid),
    SpyModule(tankId: uuid),
    ConstructionModule(tankId: uuid),
    TutorialModule(isWeekTwo: false),
], uuid: uuid)
#endif
var game: TankTacticsGame = TankTacticsGame(board: Board(objects: [
    tank,
    Tank(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .yellow, symbol: "hare"), coordinates: Coordinates(x: 3, y: 3, level: 0), playerDemographics: PlayerDemographics(firstName: "Example", lastName: "Tank", deliveryBuilding: "Newberrry Centre", deliveryType: "Carrier Pigion", deliveryNumber: "Hawkey", virtualDelivery: nil, accessibilitySettings: AccessibilitySettings(), kills: 0)),
    Wall(coordinates: Coordinates(x: 1, y: 0, level: 0)),
    ReinforcedWall(coordinates: Coordinates(x: 0, y: 0, level: 0)),
    Gift(coordinates: Coordinates(x: 1, y: 5, level: 0)),
    Tank(appearance: Appearance(fillColor: .gray, symbolColor: .red, symbol: "sos"), coordinates: Coordinates(x: 1, y: 0, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .cyan, strokeColor: .red, symbol: "circle.hexagongrid.fill"), coordinates: Coordinates(x: 3, y: 1, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .pink, strokeColor: .purple, symbolColor: .pink, symbol: "storefront.circle.fill"), coordinates: Coordinates(x: -2, y: 3, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .red, strokeColor: .green, symbol: "tree.fill"), coordinates: Coordinates(x: -4, y: -2, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .orange, symbol: "pc"), coordinates: Coordinates(x: 0, y: -3, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .cyan, symbolColor: .red, symbol: "lock.desktopcomputer"), coordinates: Coordinates(x: 3, y: -1, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .green, symbolColor: .pink, symbol: "pencil.and.list.clipboard"), coordinates: Coordinates(x: 8, y: 1, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .orange, strokeColor: .purple, symbol: "widget.extralarge.badge.plus"), coordinates: Coordinates(x: -5, y: -3, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .gray, strokeColor: .yellow, symbol: "drop.triangle.fill"), coordinates: Coordinates(x: 7, y: 4, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .cyan, symbol: "lightspectrum.horizontal"), coordinates: Coordinates(x: 6, y: -1, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .gray, symbol: "pills.fill"), coordinates: Coordinates(x: 4, y: -3, level: 0), playerDemographics: playerDemographics),
    Tank(appearance: Appearance(fillColor: .green, strokeColor: .gray, symbol: "ladybug.fill"), coordinates: Coordinates(x: -7, y: 2, level: 0), playerDemographics: playerDemographics),
]), gameDay: .monday)

func promptForDecodedFile<T: Decodable>(ofType type: T.Type) -> T? {
    let panel = NSOpenPanel()
    panel.title = "Choose a Game File"
    panel.showsResizeIndicator = true
    panel.showsHiddenFiles = false
    panel.canChooseDirectories = false
    panel.canCreateDirectories = false
    panel.allowsMultipleSelection = false
    
    if let tankTacticsGame = UTType(filenameExtension: "tanktactics") {
        panel.allowedContentTypes = [tankTacticsGame]
    }
    
    if panel.runModal() == .OK, let url = panel.url {
        do {
            let data = try? Data(contentsOf: url)
            if data == nil {
                print("data couuld not be gathered")
            }
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data!)
        } catch {
            print("Failed to decode file: \(error)")
        }
    }
    return nil
}

func promptToSaveEncodedFile<T: Encodable>(_ object: T, fileName: String) {
    let panel = NSSavePanel()
    panel.title = "Save Tank Tactics File"
    panel.canCreateDirectories = true
    panel.nameFieldStringValue = fileName
    
    if let tankTacticsGame = UTType(filenameExtension: "tanktactics") {
        panel.allowedContentTypes = [tankTacticsGame]
    }

    if panel.runModal() == .OK, let url = panel.url {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // Optional formatting
            let data = try encoder.encode(object)
            try data.write(to: url)
            print("Saved file at \(url)")
        } catch {
            print("Failed to save file: \(error)")
        }
    }
}

enum GameDay: Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    
    mutating func next() {
        switch self {
        case .monday:
            self = .tuesday
        case .tuesday:
            self = .wednesday
        case .wednesday:
            self = .thursday
        case .thursday:
            self = .friday
        case .friday:
            self = .monday
        }
    }
    
    var name: String {
        switch self {
        case .monday:
            return "Module Monday"
        case .tuesday:
            return "Treacherous Tuesday"
        case .wednesday:
            return "Wheel Wednesday"
        case .thursday:
            return "Thrifty Thursday"
        case .friday:
            return "Firearm Friday"
        }
    }
    
    var description: String {
        switch self {
        case .monday:
            return "Purchase Modules"
        case .tuesday:
            return "All action prices become 50% cheaper."
        case .wednesday:
            return "Purchase Drivetrain Upgrades"
        case .thursday:
            return "Trade and sell Uodules and Upgrades"
        case .friday:
            return "Purchase Weapon Upgrades"
        }
    }
}

@Observable class TankTacticsGame: Codable {
    var board: Board
    var gameDay: GameDay
    var randomSeed: Int
    var moduleOffered: Module? {
        if gameDay == .monday {
            switch randomSeed &* 287230 % 10 {
            case 0: return RadarModule(tankId: nil)
            case 1: return RadarModule(tankId: nil)
            case 2: return StorageModule(tankId: nil)
            case 3: return StorageModule(tankId: nil)
            case 4: return DroneModule(droneId: nil, tankId: nil)
            case 5: return SpyModule(tankId: nil)
            case 6: return ConduitModule(tankId: nil)
            case 7: return FactoryModule(tankId: nil)
            case 8: return FactoryModule(tankId: nil)
            default: return ConstructionModule(tankId: nil)
            }
        }
        return nil
    }
    
    var moduleOfferPrice: Int? {
        if gameDay == .monday {
            switch randomSeed &* 287230 % 10 {
            case 0: return 15 + randomSeed &* 3545789 % 10
            case 1: return 20 + randomSeed &* 3545789 % 10
            case 2: return 20 + randomSeed &* 3545789 % 10
            case 3: return 25 + randomSeed &* 3545789 % 10
            case 4: return 45 + randomSeed &* 3545789 % 10
            case 5: return 40 + randomSeed &* 3545789 % 10
            case 6: return 50 + randomSeed &* 3545789 % 10
            case 7: return 25 + randomSeed &* 3545789 % 10
            case 8: return 30 + randomSeed &* 3545789 % 10
            default: return 15 + randomSeed &* 3545789 % 10
            }
        }
        return nil
    }
    
    var eventCardBidders: [(UUID, Int)] = []
    
    enum CodingKeys: String, CodingKey {
        case board
        case gameDay
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode(Board.self, forKey: .board)
        self.gameDay = try container.decode(GameDay.self, forKey: .gameDay)
        self.randomSeed = Int.random(in: Int.min...Int.max)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(gameDay, forKey: .gameDay)
    }
    
    init(board: Board, gameDay: GameDay) {
        self.board = board
        self.gameDay = gameDay
        self.randomSeed = Int.random(in: Int.min...Int.max)
    }
}
