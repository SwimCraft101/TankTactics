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

extension UTType {
    static let tankTacticsGame = UTType(exportedAs: "com.hiltonsherrard.tanktactics.game")
}

final class Game: ReferenceFileDocument, ObservableObject {
    var isDeadDay: Bool { countdownToNextDeadDay == 0 }
    
    private var countdownToNextDeadDay: Int
    @Published var board: Board
    @Published var randomSeed: Int = Int.random(in: Int.min...Int.max)
    
    @Published var actions: [TankAction] = []
    
    func queueAction(_ action: TankAction) {
        actions.append(action)
    }
    
    @Published var messages: [Message] = []
    
    @Published var eventCardsToPrint: [EventCard] = []
    
    @Published var notes: [String] = []
    
    @Published var eventCardBidders: [(UUID, Int, Int)] = []
    
    private let chessGameViewModel = ChessGameViewModel()

    var chessPuzzle: ChessPuzzle? = nil
    
    func executeTurn() async {
        print("Executing Turn...")
        print("Shuffling Actions")
        actions.shuffle()
        print("Generating Chess Puzzle")
        if chessPuzzle == nil {
            chessPuzzle = await chessGameViewModel.puzzle()
        }
        print("Executing Actions Chess Puzzle")
        for action in actions {
            let _ = action.execute()
        }
        print("Generating new Random Seed")
        randomSeed = Int.random(in: Int.min...Int.max)
    }
    
    init(board: Board, countdownToNextDeadDay: Int = 2) {
        self.board = board
        self.randomSeed = Int.random(in: Int.min...Int.max)
        self.countdownToNextDeadDay = countdownToNextDeadDay
    }
    
    init() {
        self.board = Board(tanks: [Tank(uuid: UUID(), appearance: Appearance(fillColor: .gray, strokeColor: .black, symbolColor: .black, symbol: "questionmark.square.dashed"), coordinates: Coordinates(x: 0, y: 0, rotation: .random), health: 100, playerInfo: PlayerInfo(firstName: "", lastName: "", deliveryBuilding: "", deliveryType: "", deliveryNumber: "", virtualDelivery: nil, accessibilitySettings: AccessibilitySettings(), kills: 0, doVirtualDelivery: false), metal: 50, modules: [])], walls: [], oreDeposits: [], border: 5)
        self.randomSeed = Int.random(in: Int.min...Int.max)
        self.countdownToNextDeadDay = 2
    }
    
    static var readableContentTypes: [UTType] { [.tankTacticsGame] }
    static var writableContentTypes: [UTType] { [.tankTacticsGame] }
    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let decoded = try JSONDecoder().decode(SavedGame.self, from: data)
        self.board = decoded.board
        self.countdownToNextDeadDay = decoded.countdownToNextDeadDay
        self.randomSeed = Int.random(in: Int.min...Int.max)
    }
    
    // Snapshot is a plain-data copy taken synchronously on the
    // main actor before SwiftUI hands writing off to a background queue.
    func snapshot(contentType: UTType) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(SavedGame(board: board, countdownToNextDeadDay: countdownToNextDeadDay))
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
}

struct SavedGame: Codable {
    var board: Board
    var countdownToNextDeadDay: Int
}
