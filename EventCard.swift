//
//  Event Card.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 9/19/25.
//

import Foundation
import SwiftUI

enum EventCardRarity {
    case common, uncommon, rare, legendary, special
    
    var name: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .legendary: return "Legendary"
        case .special: return "Special"
        }
    }
    
    var color: Color {
        switch self {
        case .common: return .black
        case .uncommon: return .green
        case .rare: return .blue
        case .legendary: return Color(hue: 12.22, saturation: 1, brightness: 1) //gold
        case .special: return .red
        }
    }
}

//receive random player's coordinates
//"" anonymously?

enum EventCard: View {
    // COMMON CARDS
    case fuelTank, meteorite, boost, turtle
    case radarModule, storageModule, constructionModule
    
    // UNCOMMON CARDS
    case tankCaffiene, tankSteroids, sunnyDay, meteorShower, storm, moonDeerStew
    case spyModule, droneModule, factoryModule
    
    // RARE CARDS
    case forceField, smite
    case conduitModule
    
    // LEGENDARY CARDS
    case disruptor
    
    //SPECIAL CARDS
    case challenger
    
    static let all: [Self] = [
        .fuelTank, .meteorite, .boost, .turtle, .radarModule, .storageModule, .constructionModule,
        .tankCaffiene, .tankSteroids, .sunnyDay, .meteorShower, .storm, .moonDeerStew, .spyModule, .droneModule, .factoryModule,
        .forceField, .smite, .conduitModule,
        .disruptor,
        .challenger,
        
    ]
    
    var rarity: EventCardRarity {
        switch self {
        case .fuelTank, .meteorite, .boost, .turtle, .radarModule, .storageModule, .constructionModule: .common
        case .tankCaffiene, .tankSteroids, .sunnyDay, .meteorShower, .storm, .moonDeerStew, .spyModule, .droneModule, .factoryModule: .uncommon
        case .forceField, .smite, .conduitModule: .rare
        case .disruptor: .legendary
        case .challenger: .special
        }
    }
    
    init() { //picks a random Event card according to rarity. Common cards have a 6x chance, uncommon a 3x chance, rare a 2x chance, and legendary a 1x chance. Challenger has an 8x chance.
        switch Int.random(in: 0...69) {
        case 0..<4: self = .fuelTank
        case 0..<8: self = .meteorite
        case 0..<12: self = .boost
        case 0..<16: self = .turtle
        case 0..<20: self = .radarModule
        case 0..<24: self = .storageModule
        case 0..<28: self = .constructionModule
        case 0..<36: self = .challenger
        case 0..<39: self = .tankCaffiene
        case 0..<42: self = .tankSteroids
        case 0..<45: self = .sunnyDay
        case 0..<48: self = .meteorShower
        case 0..<51: self = .storm
        case 0..<54: self = .moonDeerStew
        case 0..<57: self = .spyModule
        case 0..<60: self = .droneModule
        case 0..<63: self = .factoryModule
        case 0..<65: self = .forceField
        case 0..<67: self = .smite
        case 0..<69: self = .conduitModule
        case 0..<70: self = .disruptor
            
        default: fatalError("Invalid EventCard case.")
        }
    }
    
    var body: some View {
        ZStack {
                TankTacticsHexagon()
                .fill(rarity.color)
                .stroke(.black, lineWidth: inch(0.005))
                TankTacticsHexagon()
                .fill(.white.opacity(0.9))
                .scaleEffect(0.9)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(name)
                        .font(.system(size: inch(0.25)))
                        .frame(width: inch(3.535534 - 1), height: inch(0.5), alignment: .leading)
                        .frame(width: inch(3.535534 - 0.5), height: inch(0.5), alignment: .leading)
                }
                HStack(spacing: 0) {
                    Text(description)
                        .font(.system(size: inch(0.1)))
                        .italic()
                        .frame(width: inch(3.535534 - 0.5), alignment: .leading)
                }
                if needsTankTarget {
                    Spacer()
                    Text("Target: " + String(repeating: "_", count: 36) + "  ")
                            .font(.system(size: inch(0.1)))
                            .frame(width: inch(3.535534 - 0.5), alignment: .trailing)
                }
            }
            
            .frame(width: inch(3.535534 - 0.5), height: inch(2.715679 - 0.5), alignment: .top)
        }
        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .top)
    }
    
    var name: String {
        switch self {
        case .fuelTank: return "Fuel Tank"
        case .meteorite: return "Meteorite"
        case .boost: return "Boost"
        case .turtle: return "Turtle"
            
        case .radarModule: return "Radar Module"
        case .spyModule: return "Spy Module"
        case .droneModule: return "Drone Module"
        case .conduitModule: return "Conduit Module"
        case .storageModule: return "Storage Module"
        case .constructionModule: return "Construction Module"
        case .factoryModule: return "Factory Module"
            
        case .tankCaffiene: return "Tank Caffiene"
        case .tankSteroids: return "Tank Steroids"
            
        case .sunnyDay: return "Sunny Day"
        case .meteorShower: return "Meteor Shower"
        case .storm: return "Storm"
            
        case .forceField: return "Forcefield"
        case .smite: return "Smite"
            
        case .disruptor: return "Disruptor"
        case .challenger: return "Challenger"
        case .moonDeerStew: return "Moon Deer Stew"
        }
    }
    
    var description: String {
        switch self {
        case .fuelTank: return "Immediately grants you 10 fuel."
        case .meteorite: return "Immediately grants you 10 metal."
        case .boost: return "Immediately grants you 10 health."
        case .turtle: return "Increases your defense by 10 for this turn."
        case .tankCaffiene: return "Movement Range increased by 2 for this turn."
        case .tankSteroids: return "Weapon Range increased by 2 for this turn."
        case .sunnyDay: return "All Players within 10 tiles of you gain 10 fuel."
        case .meteorShower: return "All Players within 10 tiles of you gain 10 metal."
        case .storm: return "All Players within 10 tiles of you, including yourself, take 10 damage."
        case .forceField: return "Cancels all damage to you this turn."
        case .smite: return "Deals 10 damage to a player of your choice."
        case .disruptor: return "Revokes any player's Status Card next turn."
        case .radarModule: return "Grants you a Radar Module."
        case .storageModule: return "Grants you a Storage Module."
        case .constructionModule: return "Grants you a Construction Module."
        case .spyModule: return "Grants you a Spy Module."
        case .droneModule: return "Grants you a Drone Module."
        case .factoryModule: return "Grants you a Factory Module."
        case .conduitModule: return "Grants you a Conduit Module."
        case .challenger: return "You may issue a Challenge to another player. A Challenge is a competition of your choice adjudicated directly by the Game Operator. Examples include a chess match, a basketball 1v1, or a game of rock-paper-scissors. They may decline or accept the Challenge. You should clear up the terms with your challengee in advance as if they decline, you lose this card. Make sure to write the Challenge on the back of this card. The winner of the Challenge gains 20 Fuel and 20 Metal."
        case .moonDeerStew: return "Using this card feeds Moon Deer Stew to your entire crew. Once used, you have a 25% chance of receiving three random event cards. Otherwise, you do not recieve a status card on the next turn."
        }
    }
    
    var needsTankTarget: Bool {
        switch self {
        case .smite, .disruptor, .challenger: return true
        default: return false
        }
    }
    
    func preExecute(by tank: Tank, target: BoardObject? = nil) { // Runs before turn.
        switch self {
        case .fuelTank:
            tank.fuel += 10
            return
        case .meteorite:
            tank.metal += 10
            return
        case .boost:
            tank.health += 10
            return
        case .turtle:
            tank.defense += 10
            return
        case .tankCaffiene:
            tank.movementRange += 2
            return
        case .tankSteroids:
            tank.gunRange += 2
            return
        case .sunnyDay:
            for object in Game.shared.board.objects {
                if let targetTank = object as? Tank {
                    if targetTank.coordinates!.distanceTo(tank.coordinates!) > 10 { continue }
                    targetTank.fuel += 10
                }
            }
            return
        case .meteorShower:
            for object in Game.shared.board.objects {
                if let targetTank = object as? Tank {
                    if targetTank.coordinates!.distanceTo(tank.coordinates!) > 10 { continue }
                    targetTank.metal += 10
                }
            }
            return
        case .storm:
            for object in Game.shared.board.objects {
                if let targetTank = object as? Tank {
                    if targetTank.coordinates!.distanceTo(tank.coordinates!) > 10 { continue }
                    targetTank.health -= 10
                }
            }
            return
        case .forceField:
            tank.defense += 1000
        case .smite:
            target!.health -= 10
        case .disruptor:
            Game.shared.notes.append("Do not deliver a Status Card to \((target! as! Player).playerInfo.fullName)! They were Disrupted by \(tank.playerInfo.fullName).")
        case .radarModule:
            tank.modules.append(RadarModule(tankId: nil))
            return
        case .storageModule:
            tank.modules.append(StorageModule(tankId: nil))
            return
        case .constructionModule:
            tank.modules.append(ConstructionModule(tankId: nil))
            return
        case .spyModule:
            tank.modules.append(SpyModule(tankId: nil))
            return
        case .droneModule:
            let droneId = UUID()
            Game.shared.board.objects.append(Drone(coordinates: Coordinates(x: Int.random(in: -10...10), y: Int.random(in: -10...10)), uuid: droneId))
            tank.modules.append(DroneModule(droneId: droneId, tankId: nil))
            return
        case .factoryModule:
            tank.modules.append(FactoryModule(tankId: nil))
            return
        case .conduitModule:
            tank.modules.append(ConduitModule(tankId: nil))
            return
        case .challenger: return
        case .moonDeerStew:
            if Int.random(in: 0...3) == 0 {
                for _ in 1...3 {
                    let card = Self.init()
                    Game.shared.eventCardsToPrint.append(card)
                    Game.shared.notes.append("Give \(tank.playerInfo.fullName) the \(card.name) Event Card.")
                }
            } else {
                Game.shared.notes.append("Do not deliver a Status Card to \((target! as! Player).playerInfo.fullName)! They ate Moon Deer Stew!")
            }
        }
    }
    
    func postExecute(by tank: Tank) { // Runs after turn. Allows for temporary boosts in stats like MovementRange.
        switch self {
        case .fuelTank: return
        case .meteorite: return
        case .boost: return
        case .turtle:
            tank.defense -= 10
            return
        case .tankCaffiene:
            tank.movementRange -= 2
            return
        case .tankSteroids:
            tank.gunRange -= 2
            return
        case .sunnyDay: return
        case .meteorShower: return
        case .storm: return
        case .forceField:
            tank.defense -= 1000
        case .smite: return
        case .disruptor: return
        case .radarModule: return
        case .storageModule: return
        case .constructionModule: return
        case .spyModule: return
        case .droneModule: return
        case .factoryModule: return
        case .conduitModule: return
        case .challenger: return
        case .moonDeerStew: return
        }
    }
}

#Preview {
    VStack {
        EventCard.disruptor
        
        EventCard()
    }
}
