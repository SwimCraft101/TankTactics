//
//  Game.shared.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import SwiftUI

func promptForDecodedFile<T: Decodable>(ofType type: T.Type) -> T? {
    let panel = NSOpenPanel()
    panel.title = "Choose a game File"
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
                print("data could not be gathered")
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
    case mondayNormal
    case tuesdayNormal
    case wednesdayNormal
    case thursdayNormal
    case fridayNormal
    case deadMonday
    case deadTuesday
    case deadWednesday
    case deadThursday
    case deadFriday
    
    func next() -> Self {
        switch self {
        case .mondayNormal:
            return .deadTuesday
        case .tuesdayNormal:
            return .deadWednesday
        case .wednesdayNormal:
            return .deadThursday
        case .thursdayNormal:
            return .deadFriday
        case .fridayNormal:
            return .deadMonday
        case .deadMonday:
            return .tuesdayNormal
        case .deadTuesday:
            return .wednesdayNormal
        case .deadWednesday:
            return .thursdayNormal
        case .deadThursday:
            return .fridayNormal
        case .deadFriday:
            return .mondayNormal
        }
    }
    
    var name: String {
        switch self {
        case .mondayNormal, .deadMonday:
            return "Module Monday"
        case .tuesdayNormal, .deadTuesday:
            return "Treacherous Tuesday"
        case .wednesdayNormal, .deadWednesday:
            return "Wheel Wednesday"
        case .thursdayNormal, .deadThursday:
            return "Thrifty Thursday"
        case .fridayNormal, .deadFriday:
            return "Firearm Friday"
        }
    }
    
    var isDeadDay: Bool {
        switch self {
        case .deadMonday, .deadTuesday, .deadWednesday, .deadThursday, .deadFriday:
            return true
        default:
            return false
        }
    }
}

@Observable
final class Game: Codable {
    static var shared: Game = Game(board: Board(tanks: [], walls: [], oreDeposits: [], border: 5), gameDay: .mondayNormal)
    
    var board: Board
    var gameDay: GameDay
    var nextGameDay: GameDay
    var randomSeed: Int
    
    var actions: [any TankAction] = []
    
    func queueAction(_ action: any TankAction) {
        actions.append(action)
    }
    
    var messages: [Message] = []
    
    var eventCardsToPrint: [EventCard] = []
    
    var notes: [String] = []
    
    var eventCardBidders: [(UUID, Int, Int)] = []
    
    private let chessPuzzleTask: Task<ChessPuzzle, Never> = Task {
        await ChessGameViewModel.shared.puzzle()
    }

    var chessPuzzle: ChessPuzzle {
        get async {
            await chessPuzzleTask.value
        }
    }
    
    func executeTurn() {
        actions.shuffle()
        
        for action in actions {
            let _ = action.execute()
        }
        #warning("Event card bidding")
        
        gameDay = nextGameDay
        nextGameDay = gameDay.next()
        randomSeed = Int.random(in: Int.min...Int.max)
    }
    
    enum CodingKeys: String, CodingKey {
        case board
        case newGameDay
        case randomSeed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode(Board.self, forKey: .board)
        self.gameDay = try container.decodeIfPresent(GameDay.self, forKey: .newGameDay) ?? .mondayNormal
        self.nextGameDay = .mondayNormal //will be changed soon..
        self.randomSeed = (try? container.decode(Int.self, forKey: .randomSeed)) ?? Int.random(in: Int.min...Int.max)
        self.nextGameDay = gameDay.next()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(gameDay, forKey: .newGameDay)
        try container.encode(randomSeed, forKey: .randomSeed)
    }
    
    init(board: Board, gameDay: GameDay) {
        self.board = board
        self.gameDay = gameDay
        self.nextGameDay = gameDay.next()
        self.randomSeed = Int.random(in: Int.min...Int.max)
    }
}
