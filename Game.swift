//
//  Game.shared.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import SwiftUICore
#if DEBUG
let playerInfo = PlayerInfo(firstName: "Example", lastName: "Tank", deliveryBuilding: "Newberrry Centre", deliveryType: "Carrier Pigion", deliveryNumber: "Hawkey", virtualDelivery: nil, accessibilitySettings: AccessibilitySettings(), kills: 0, doVirtualDelivery: false)
let uuid = UUID()
let tank = Tank(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .black, symbol: "xmark.triangle.circle.square"), coordinates: Coordinates(x: 0, y: 0), playerInfo: PlayerInfo(firstName: "first", lastName: "last", deliveryBuilding: "building", deliveryType: "type", deliveryNumber: "num", virtualDelivery: "email", accessibilitySettings: AccessibilitySettings(highContrast: false, colorblind: false, largeText: false), kills: 0, doVirtualDelivery: false), fuel: 20, metal: 30, health: 84, defense: 2, movementCost: 10, movementRange: 2, gunRange: 2, gunDamage: 10, gunCost: 9, highDetailSightRange: 3, lowDetailSightRange: 4, radarRange: 5, modules: [
        ConduitModule(tankId: uuid),
        ConduitModule(tankId: uuid),
        StorageModule(tankId: uuid),
        SpyModule(tankId: uuid),
        TutorialModule(isWeekTwo: false),
        RadarModule(tankId: uuid),
], uuid: uuid)
#endif

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

@Observable
final class Game: Codable {
    static var shared: Game = Game(board: Board(objects: [
        tank,
        Tank(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .yellow, symbol: "hare"), coordinates: Coordinates(x: 3, y: 3, level: 0), playerInfo: PlayerInfo(firstName: "Example", lastName: "Tank", deliveryBuilding: "Newberrry Centreee", deliveryType: "Carrier Pigion", deliveryNumber: "Hawkey", virtualDelivery: nil, accessibilitySettings: AccessibilitySettings(), kills: 0, doVirtualDelivery: false)),
        Wall(coordinates: Coordinates(x: 1, y: 0, level: 0)),
        ReinforcedWall(coordinates: Coordinates(x: 0, y: 0, level: 0)),
        Gift(coordinates: Coordinates(x: 1, y: 5, level: 0)),
        Tank(appearance: Appearance(fillColor: .gray, symbolColor: .red, symbol: "sos"), coordinates: Coordinates(x: 1, y: 0, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .cyan, strokeColor: .red, symbol: "circle.hexagongrid.fill"), coordinates: Coordinates(x: 3, y: 1, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .pink, strokeColor: .purple, symbolColor: .pink, symbol: "storefront.circle.fill"), coordinates: Coordinates(x: -2, y: 3, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .red, strokeColor: .green, symbol: "tree.fill"), coordinates: Coordinates(x: -4, y: -2, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .orange, symbol: "pc"), coordinates: Coordinates(x: 0, y: -3, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .cyan, symbolColor: .red, symbol: "lock.desktopcomputer"), coordinates: Coordinates(x: 3, y: -1, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .green, symbolColor: .pink, symbol: "pencil.and.list.clipboard"), coordinates: Coordinates(x: 8, y: 1, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .orange, strokeColor: .purple, symbol: "widget.extralarge.badge.plus"), coordinates: Coordinates(x: -5, y: -3, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .gray, strokeColor: .yellow, symbol: "drop.triangle.fill"), coordinates: Coordinates(x: 7, y: 4, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .cyan, symbol: "lightspectrum.horizontal"), coordinates: Coordinates(x: 6, y: -1, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .gray, symbol: "pills.fill"), coordinates: Coordinates(x: 4, y: -3, level: 0), playerInfo: playerInfo),
        Tank(appearance: Appearance(fillColor: .green, strokeColor: .gray, symbol: "ladybug.fill"), coordinates: Coordinates(x: -7, y: 2, level: 0), playerInfo: playerInfo),
        Drone(coordinates: Coordinates(x: 4, y: -3), uuid: UUID())
    ], border: 7), gameDay: .monday)
    
    var board: Board
    var gameDay: GameDay
    var randomSeed: Int
    
    var actions: [TankAction] = []
    
    func queueAction(_ action: TankAction) {
        actions.append(action)
        actions.sort(by: { $0.precedence > $1.precedence })
    }
    
    var messages: [Message] = []
    
    var eventCardsToPrint: [EventCard] = []
    
    var notes: [String] = []
    
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
    
    var eventCardBidders: [(UUID, Int, Int)] = []
    
    func executeTurn() {
        Tank.bindModules()
        actions.shuffle()
        actions.sort(by: { $0.precedence > $1.precedence })
        
        for object in Game.shared.board.objects {
            if let tank = object as? Tank {
                tank.constrainToMaximumValues()
            }
        }
        
        for action in actions {
            let _ = action.execute()
            for object in board.objects {
                if object.health <= 0 {
                    if object is Tank { fatalError("A Tank has died!! pleas implement this") }
                    board.objects.removeAll(where: { $0 == object })
                }
            }
        }
        Tank.bindModules();
        {
            if eventCardBidders.count >= 3 {
                eventCardBidders.sort(by: { $0.1 + $0.2 > $1.1 + $1.2 })
                if gameDay == .tuesday {
                    if eventCardBidders[0].1 + eventCardBidders[0].2 == eventCardBidders[2].1 + eventCardBidders[2].2 { //if there is a 3-way tie or worse
                        return
                    }
                    let card = EventCard()
                    eventCardsToPrint.append(card)
                    (Game.shared.board.objects.first { $0.uuid == eventCardBidders[1].0 } as! Tank).fuel -= eventCardBidders[1].1
                    (Game.shared.board.objects.first { $0.uuid == eventCardBidders[1].0 } as! Tank).metal -= eventCardBidders[1].2
                    Game.shared.notes.append("Give \((Game.shared.board.objects.first { $0.uuid == eventCardBidders[1].0 } as! Player).playerInfo.fullName) the \(card.name) Event Card.")
                } else {
                    if eventCardBidders[0].1 + eventCardBidders[0].2 == eventCardBidders[1].1 + eventCardBidders[1].2 { //if there is a tie or worse
                        return
                    }
                }
                let card = EventCard()
                eventCardsToPrint.append(card)
                (Game.shared.board.objects.first { $0.uuid == eventCardBidders[0].0 } as! Tank).fuel -= eventCardBidders[0].1
                (Game.shared.board.objects.first { $0.uuid == eventCardBidders[0].0 } as! Tank).metal -= eventCardBidders[0].2
                Game.shared.notes.append("Give \((Game.shared.board.objects.first { $0.uuid == eventCardBidders[0].0 } as! Player).playerInfo.fullName) the \(card.name) Event Card.")
            }
        }()
        Tank.bindModules()
        var fuelPerTank = 0
        while fuelPerTank < 25 {
            var totalTankFuel: Int = 0
            for tank in board.objects.filter({ $0 is Tank }) as! [Tank] {
                tank.constrainToMaximumValues()
                totalTankFuel += tank.fuel
            }
            let numberOfTanks: Int = board.objects.filter({ $0 is Tank }).count
            fuelPerTank = totalTankFuel / numberOfTanks
            
            board.objects.append(Gift(coordinates: Coordinates(x: Int.random(in: -10...10), y: Int.random(in: -10...10))))
            board.objects.append(Gift(coordinates: Coordinates(x: Int.random(in: -10...10), y: Int.random(in: -10...10))))
            board.objects.append(Gift(coordinates: Coordinates(x: Int.random(in: -10...10), y: Int.random(in: -10...10))))
            
            for tank in board.objects.filter({ $0 is Tank }) as! [Tank] {
                tank.fuel += 1
                tank.constrainToMaximumValues()
            }
        }
        gameDay.next()
        randomSeed = Int.random(in: Int.min...Int.max) 
        saveTurnToPDF(players: (board.objects.filter({ $0 is Player }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), messages: messages.filter({ message in
            !(board.objects.first { $0.uuid == message.recipient } as! Player).playerInfo.doVirtualDelivery }), eventCards: eventCardsToPrint, notes: notes, doAlignmentCompensation: true)
        notes.removeAll()
        eventCardsToPrint.removeAll()
        actions.removeAll()
        messages.removeAll()
    }
    
    enum CodingKeys: String, CodingKey {
        case board
        case gameDay
        case randomSeed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode(Board.self, forKey: .board)
        self.gameDay = try container.decode(GameDay.self, forKey: .gameDay)
        self.randomSeed = (try? container.decode(Int.self, forKey: .randomSeed)) ?? Int.random(in: Int.min...Int.max)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(gameDay, forKey: .gameDay)
        try container.encode(randomSeed, forKey: .randomSeed)
    }
    
    init(board: Board, gameDay: GameDay) {
        self.board = board
        self.gameDay = gameDay
        self.randomSeed = Int.random(in: Int.min...Int.max)
    }
}
