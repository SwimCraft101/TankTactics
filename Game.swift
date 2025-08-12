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

var game: TankTacticsGame = TankTacticsGame(board: Board(objects: [
    BoardObject(fuelDropped: 0, metalDropped: 0, appearance: Appearance(fillColor: .blue, strokeColor: .green, symbolColor: .green, symbol: "tree"), coordinates: Coordinates(x: 1, y: 0, level: 0), health: 54, defense: 31),
    Wall(coordinates: Coordinates(x: 0, y: 0, level: 0)),
    Gift(coordinates: Coordinates(x: 1, y: 5, level: 0)),
    Placeholder(coordinates: Coordinates(x: -1, y: 8, level: 0)),
    Placeholder(coordinates: Coordinates(x: -1, y: 7, level: 0)),
    Gift(coordinates: Coordinates(x: -1, y: 6, level: 0)),
                                                                   ]), gameDay: .wednesday)

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
    
    enum CodingKeys: String, CodingKey {
        case board
        case gameDay
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode(Board.self, forKey: .board)
        self.gameDay = try container.decode(GameDay.self, forKey: .gameDay)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(gameDay, forKey: .gameDay)
    }
    
    init(board: Board, gameDay: GameDay) {
        self.board = board
        self.gameDay = gameDay
    }
}
