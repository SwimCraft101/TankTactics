//
//  Module.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/5/25.
//

import Foundation
import SwiftUI

struct ModuleView: View {
    let module: Module
    var body: some View {
        AnyView(module.view)
            .frame(width: inch(4), height: inch(4))
    }
}

enum ModuleType: String, Codable {
    case tutorial
    case websitePlug
    case radar
    case spy
    case drone
    case conduit
    case storage
    case module

    func name() -> String {
        switch self {
        case .tutorial, .websitePlug: return "Tutorial"
        case .radar: return "Radar"
        case .spy: return "Spy"
        case .drone: return "Drone"
        case .conduit: return "Conduit"
        case .storage: return "Storage"
        case .module: return "SOMETHING IS VERY WRONG"
        }
    }
}

class Module: Codable { var type: ModuleType { .module }
    var tankId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    var view: any View {
        Text("This is a base-class Module. Subclasses should override this property. If you're seeing this, something has gone VERY WRONG.")
            .font(.system(size: inch(0.3)))
    }
    
    init(tankId: UUID?) {
        self.tankId = tankId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
    
    static func decode(from decoder: Decoder) throws -> Module {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ModuleType.self, forKey: .type)

        switch type {
        case .tutorial:
            return try TutorialModule(from: decoder)
        case .websitePlug:
            return try WebsitePlugModule(from: decoder)
        case .radar:
            return try RadarModule(from: decoder)
        case .spy:
            return try SpyModule(from: decoder)
        case .drone:
            return try DroneModule(from: decoder)
        case .conduit:
            return try ConduitModule(from: decoder)
        case .storage:
            return try StorageModule(from: decoder)
        case .module:
            return try Module(from: decoder)
        }
    }
    
    required init(from decoder: Decoder) throws {
        tankId = nil
    }
    
    static func random() -> Module { //MARK: rework module rarity for random modules
        switch Int.random(in: 1...2) {
        case 1:
            return RadarModule(tankId: nil)
        case 2:
            return RadarModule(tankId: nil)
        default:
            return RadarModule(tankId: nil)
        }
    }
}

extension Module {
    static func encodeArray(_ modules: [Module]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(modules)
    }
    
    static func decodeArray(from data: Data) throws -> [Module] {
        let decoder = JSONDecoder()
        let rawObjects = try decoder.decode([PolymorphicContainer].self, from: data)
        return rawObjects.map { $0.module }
    }
    
    // Private helper for decoding
    private struct PolymorphicContainer: Decodable {
        let module: Module
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Module.CodingKeys.self)
            let type = try container.decode(ModuleType.self, forKey: .type)
            
            switch type {
            case .tutorial:
                self.module = try TutorialModule(from: decoder)
            case .websitePlug:
                self.module = try WebsitePlugModule(from: decoder)
            case .radar:
                self.module = try RadarModule(from: decoder)
            case .spy:
                self.module = try SpyModule(from: decoder)
            case .drone:
                self.module = try DroneModule(from: decoder)
            case .conduit:
                self.module = try ConduitModule(from: decoder)
            case .storage:
                self.module = try StorageModule(from: decoder)
            case .module:
                self.module = try Module(from: decoder)
            }
        }
    }
}

class TutorialModule: Module { override var type: ModuleType { .tutorial } //MARK: Fact check all info for changed details, add icon references
    let isWeekTwo: Bool
    override var view: any View {
        if !isWeekTwo {
            switch game.gameDay {
            case .monday:
                Text("""
                    Welcome to Tank Tactics!
                    This is the Tutorial Module, a system designed to teach you how to play Tank Tactics during your first two weeks of gameplay. You will be guided through all the important information to playing Tank Tactics. Note that some information will be intentionally vauge, as some elements of the game are not publicly documented in detail to preserve the strategy of wielding knowledge tactfully.
                    The upper triangle flap is the Viewport (􀎹). The Viewport (􀎹) shows the perspective of your Tank in the direction that it is facing. Note that you cannot see the orientations of other Tanks. The Viewport always shows tiles on the board exactly as they appear. Information about what these tiles are, and how to understand the Viewport (􀎹), will be given later.
                    
                            Accessibility Options:
                    􀂒 􀀂 Enable High Contrast Mode
                    􀂒 􀝥 Enable Colorblind Mode
                    􀂒 􀅐 Enable Large Text Mode
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.tuesday:
                Text("""
                    There are two main currencies in Tank Tactics: Fuel (􀵞), and Metal (􀇷). Fuel is used to take direct actions on the board, whereas Metal is used for upgrading your Tank. You may withdraw Fuel and Metal in their physical form (􀐚) to trade freely with other people, however Tank Tactics does not take responsibility for the result of thefts and will not replace stolen Fuel and Metal Tokens (􀐚). Fuel and Metal Tokens may also be found around campus. You can use Fuel and Metal Tokens (􀐚) by folding them into your Status Card before submitting it, however the total of Fuel and Metal inside your tank, including tokens submitted that turn, must not exceed 50 each.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.wednesday:
                Text("""
                    There are two primary actions you can take on your turn. These are: Moving your tank (􁹫) and Firing your weapons (􀅾).
                    To Move your tank, draw a 􁹫 over a tile in the viewport. The orientation of the triangle determines the rotation of your tank by which way the viewport would face relative to your current orientation. You should choose the orientation of your tank carefully when moving, as you cannot move or fire directly behind you. Additionally, you may draw a line indicating the exact path your tank should take. You can only move one square per turn by default, however, this can be increased by purchasing the Movement Speed upgrade.
                    To Fire your weapons, draw a(n) 􀅾 over a tile in the viewport. Additionally, you may draw a line indicating the exact path your missile should take. Note that if the tank you are firing on moves before you fire, you may miss them. You can only fire one square away by default, however, this can be increased by purchasing the Weapon Range upgrade.    
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.thursday:
                VStack {
                    Text("""
                        There are many types of objects you can encounter on the board in Tank Tactics. Example images are below in order of description. A Solid tile cannot be moved through, and will have a background that is not white. A Rigid tile cannot be fired through, but bullets landing on an non-Rigid tile may be able to destroy it.
                        The first, and most important, type of object is the Tank. Tanks are both Solid and Rigid. Tanks will be composed of at least two colors, making them easy to recognize. Tanks on the board represent other players in the game. 
                        Second, Walls. Walls are both Solid and Rigid. Walls are depicted as solid black.
                        Third, Gifts. Gifts are neither Solid nor Rigid, but are destroyed if fired at directly. Gifts can contain Fuel and Metal, or, in rare cases, a Module. Gifts containing only one type of benefit will, instead of the gift icon, show the icon for their respective contents. Gifts are automatically collected when you pass through or land on them whilst moving.
                """).font(.system(size: inch(0.15)))
                    HStack(spacing: 0) {
                        let coordinates = Coordinates(x: 0, y: 0, level: 0)
                        BasicTileView(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .black, symbol: "xmark.triangle.circle.square"))
                        BasicTileView(appearance: Appearance(fillColor: .green, strokeColor: .green, symbolColor: .red, symbol: "sos"))
                        BasicTileView(appearance: Wall(coordinates: coordinates).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 1, metalReward: 1, containedModule: nil, uuid: nil).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 1, metalReward: 0, containedModule: nil, uuid: nil).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 0, metalReward: 1, containedModule: nil, uuid: nil).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 0, metalReward: 0, containedModule: TutorialModule(isWeekTwo: false), uuid: nil).appearance)
                    }
                    .frame(height: inch(0.5), alignment: .bottom)
                }
                .frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.friday:
                Text("""
                            Each day of the week is given a special name and purpose in Tank Tactics. A description of each follows, with more detail being given next week. The actions for each day are taken on the lower triangle flap.:
                        􀯇 Module Monday 􀯇
                            Purchase new Modules for your Tank
                        􀇾 Treacherous Tuesday 􀇾
                            All actions become 50% cheaper.
                        􂥰 Wheel Wednesday 􂥰
                            Purchase Drivetrain Upgrades for your Tank.
                        􁽇 Thrifty Thursday 􁽇
                            Trade and sell Modules and Upgrades
                        􀾲 Firearm Friday 􀾲
                            Purchase Weapon Upgrades for your Tank
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            }
        } else {
            switch game.gameDay {
            case .monday:
                Text("""
                        Modules (􀯇) are a system of special actions and effects in Tank Tactics. On every Monday, every player will receive identical offers to purchase Modules for their Tank. Purchasing Modules places them in your Status Card indefinitely, however, only two modules can be equipped at a time under normal circumstances. If you have too many Modules, all of your Modules will be inoperable until you select two of them. Modules are not publicly documented in detail, but a link to a video explaining any module is available on request for players with that module.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.tuesday:
                Text("""
                        On Treacherous Tuesdays (􀇾), all actions are 50% cheaper. This means that this day is ideal for mounting an attack or taking more actions than usual. Because of this rapid sequence of actions, a new system for ordering actions is availible. Read on.
                
                        Precedence (􁘿) is a system determining which actions are processed first. Precedence works by a blind bidding system, where whoever pays the most Fuel will be first. For example, if Tank Blue Triangle wants to fire and hit Tank Red Square, she might add precedence to her move, as Tank Red Square might try to move before she can hit him. Therefore, each player is incentivized to spend more Fuel on Precedence, but spending too much can lead to the disaster of being out of Fuel. If two or more players have the same precedence for an action, the order between them is determined randomly.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.wednesday:
                Text("""
                        Wheel Wednesday (􂥰) is the day when you can purchase upgrades for your Tank's drivetrain. There are two different upgrades you can make. Movement Efficiency, and Movement Speed. Movement Efficiency reduces the cost in fuel it takes to move. Movement Speed increases the distance you can move per turn.
                
                        Event Cards (􀈿) are a system of special actions in Tank Tactics. Similar to Precedence, whoever bids the most fuel or metal on a day will recieve an Event Card, however, only the highest bidder will actually pay for the card. Event Cards are not publicly documented in detail, but the card descriptions are clear and should not cause confusion. If you have any questions about a specific event card or Tank Tactics as a whole, talk to the Game Operator.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.thursday:
                Text("""
                        On Thrifty Thursdays, you can sell your Tank's Modules and Upgrades to receive metal and/or fuel back for them. This will be necessarily less than you purchased them for. The offers may vary somewhat over time.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.friday:
                Text("""
                        On Firearm Fridays, you can purchase several upgrades for your Tank's weapons. There are three different upgrades you can normally make. Weapon Range increases the distance you can fire away from your Tank. Weapon Damage increases the amount of damage your weapon deals. Weapon Efficiency reduces the cost to fire your weapon.
                
                        You have reached the end of the Tutorial Module. It will disappear automatically before your next turn. Good luck, and enjoy Tank Tactics!
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            }
        }
    }
    
    init(isWeekTwo: Bool) {
        self.isWeekTwo = isWeekTwo
        super.init(tankId: nil)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case isWeekTwo
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isWeekTwo, forKey: .isWeekTwo)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isWeekTwo = try container.decode(Bool.self, forKey: .isWeekTwo)
        try super.init(from: decoder)
    }
}

class WebsitePlugModule: Module { override var type: ModuleType { .websitePlug } // note that this subclass needs no special encoder and decoder logic as it stores no extra data.
    override var view: any View {
        Image("youtube") //MARK: Make QR Code of the Tank Tactics Website on Google Sites, add as image reference, reference here.
    }
}

class RadarModule: Module { override var type: ModuleType { .radar } // note that this subclass needs no special encoder and decoder logic as it stores no extra data.
    override var view: any View {
        SquareViewport(coordinates: game.board.objects.first(where: { $0.uuid == tankId! })!.coordinates!, viewRenderSize: 5, highDetailSightRange: 0, lowDetailSightRange: 0, radarRange: 50000, showBorderWarning: false)
    }
}

class DroneModule: Module { override var type: ModuleType { .drone }
    var droneId: UUID
    override var view: any View {
        VStack {
            SquareViewport(coordinates: game.board.objects.filter({ $0.uuid == droneId }).first!.coordinates!, viewRenderSize: 3, highDetailSightRange: 3, lowDetailSightRange: 3, radarRange: 3, showBorderWarning: false) //MARK: reference real state of value showBorderWarning
        }
    }
    
    init(droneId: UUID) {
        self.droneId = droneId
        super.init(tankId: nil)
    }
    
    enum CodingKeys: String, CodingKey {
        case droneId
        case type
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(droneId, forKey: .droneId)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.droneId = try container.decode(UUID.self, forKey: .droneId)
        try super.init(from: decoder)
    }
}

class SpyModule: Module { override var type: ModuleType { .spy } // note that this subclass needs no special encoder and decoder logic as it stores no extra data.
    override var view: any View {
        VStack(spacing: inch(0.1)) {
            Text("All other tanks within 5 tiles are listed.")
                .font(.system(size: inch(0.2)))
                .italic()
            VStack(spacing: 0) {
                ForEach(game.board.objects.filter({
                    if $0 is Tank {
                        if $0.uuid != self.tankId && self.tankId != nil {
                            if $0.coordinates != nil {
                                if $0.coordinates!.distanceTo(game.board.objects.filter({ $0.uuid == self.tankId }).first!.coordinates!) <= 5 {
                                    return true
                                }
                            }
                        }
                    }
                    return false
                }) as! [Tank]) { tank in
                    HStack(spacing: inch(0.1)) {
                        BasicTileView(appearance: tank.appearance)
                            .frame(maxWidth: inch(0.5), maxHeight: inch(0.5))
                        Text("\(tank.health)􀞽")
                            .font(.system(size: inch(0.2)))
                        VStack {
                            Text("\(tank.fuel)􀵞")
                                .font(.system(size: inch(0.15)))
                            Text("\(tank.metal)􀇷")
                                .font(.system(size: inch(0.15)))
                        }
                        VStack {
                            Text("\(tank.movementCost)􀍾")
                                .font(.system(size: inch(0.15)))
                            Text("\(tank.movementRange)􂊼")
                                .font(.system(size: inch(0.15)))
                        }
                        VStack {
                            Text("\(tank.gunCost)􀣉")
                                .font(.system(size: inch(0.15)))
                            Text("\(tank.gunRange)􂇏")
                                .font(.system(size: inch(0.15)))
                        }
                        VStack {
                            Text("\(tank.gunDamage)􀎓")
                                .font(.system(size: inch(0.15)))
                            Text("\(tank.defense)􀙨")
                                .font(.system(size: inch(0.15)))
                        }
                        HStack(spacing: 0) {
                            VStack {
                                if tank.modules.count > 0 {
                                    Text("\(tank.modules[0].type.name())")
                                        .font(.system(size: inch(0.15)))
                                        .lineLimit(1)
                                } else {
                                    Text("Empty")
                                        .font(.system(size: inch(0.15)))
                                        .italic()
                                        .fontWeight(.thin)
                                        .lineLimit(1)
                                }
                                if tank.modules.count > 1 {
                                    Text("\(tank.modules[1].type.name())")
                                        .font(.system(size: inch(0.15)))
                                        .lineLimit(1)
                                } else {
                                    Text("Empty")
                                        .font(.system(size: inch(0.15)))
                                        .italic()
                                        .fontWeight(.thin)
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                    }
                    .frame(width: inch(4), alignment: .leading)
                }
                Spacer()
            }
        }
    }
}

class ConduitModule: Module { override var type: ModuleType { .conduit } /// note that this subclass needs no special encoder and decoder logic as it stores no extra data. The modules contained in the conduit are simply taken from the Tank's `modules` array. All logic for displaying the connected modules within the Conduit is processed in the `StatusCard` code.
    override var view: any View { //displays only when tank has a conduit within another Conduit.
        Text("Unfortunately, Conduits may not be nested within each other.")
            .font(.system(size: inch(0.3)))
    }
}

class StorageModule: Module { override var type: ModuleType { .storage }
    var tank: Tank {
        game.board.objects.first(where: { $0.uuid == self.tankId })! as! Tank
    }
    
    override var view: any View {
        VStack(spacing: inch(0.25)) {
            HStack(spacing: inch(0.25)) {
                Text("\(tank.fuel)􀵞")
                    .font(.system(size: inch(0.75)))
                Text("\(tank.metal)􀇷")
                    .font(.system(size: inch(0.75)))
            }
            if true/*MARK: tank active modules count*/ {
                Text("Stored Module: \(tank.modules[0/*MARK: tank active modules system*/].type.name())")
                    .font(.system(size: inch(0.25)))
            } else {
                Text("No module is stored")
                    .font(.system(size: inch(0.25)))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.white
        ModuleView(module: StorageModule(tankId: game.board.objects.first(where: { $0 is Tank })?.uuid ?? UUID()))
    }
}
