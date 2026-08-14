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
    case meteorite, boost
    case radarModule, storageModule, constructionModule
    
    // UNCOMMON CARDS
    case meteorShower, storm, moonDeerStew
    case spyModule, droneModule
    
    // RARE CARDS
    case smite
    case conduitModule
    
    // LEGENDARY CARDS
    case disruptor
    
    //SPECIAL CARDS
    case challenger
    
    static let all: [Self] = [
        .meteorite, .boost, .radarModule, .storageModule, .constructionModule,
        .meteorShower, .storm, .moonDeerStew, .spyModule, .droneModule,
        .smite, .conduitModule,
        .disruptor,
        .challenger,
        
    ]
    
    var rarity: EventCardRarity {
        switch self {
        case .meteorite, .boost, .radarModule, .storageModule, .constructionModule: .common
        case .meteorShower, .storm, .moonDeerStew, .spyModule, .droneModule: .uncommon
        case .smite, .conduitModule: .rare
        case .disruptor: .legendary
        case .challenger: .special
        }
    }
    
    init() { //picks a random Event card according to rarity. Common cards have a 6x chance, uncommon a 3x chance, rare a 2x chance, and legendary a 1x chance. Challenger has an 8x chance.
        fatalError("Random Event Cards yet to be implemented.")
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
                    ViewThatFits {
                        Text(description)
                            .font(.system(size: inch(0.2)))
                            .italic()
                            .frame(width: inch(3.535534 - 0.5), alignment: .leading)
                        Text(description)
                            .font(.system(size: inch(0.15)))
                            .italic()
                            .frame(width: inch(3.535534 - 0.5), alignment: .leading)
                        Text(description)
                            .font(.system(size: inch(0.1)))
                            .italic()
                            .frame(width: inch(3.535534 - 0.5), alignment: .leading)
                    }
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
        case .meteorite: return "Meteorite"
        case .boost: return "Boost"
            
        case .radarModule: return "Radar Module"
        case .spyModule: return "Spy Module"
        case .droneModule: return "Drone Module"
        case .conduitModule: return "Conduit Module"
        case .storageModule: return "Storage Module"
        case .constructionModule: return "Construction Module"
                
        case .meteorShower: return "Meteor Shower"
        case .storm: return "Storm"
        
        case .smite: return "Smite"
            
        case .disruptor: return "Disruptor"
        case .challenger: return "Challenger"
        case .moonDeerStew: return "Moon Deer Stew"
        }
    }
    
    var description: String {
        switch self {
        case .meteorite: return "Immediately grants you 10 metal."
        case .boost: return "Immediately grants you 10 health."
        case .meteorShower: return "All Players within 10 tiles of you gain 10 metal."
        case .storm: return "All Players within 10 tiles of you, including yourself, take 10 damage."
        case .smite: return "Deals 10 damage to a player of your choice."
        case .disruptor: return "Revokes any player's Status Card next turn."
        case .radarModule: return "Grants you a Radar Module. Radar Modules allow you to see farther and in all directions, but you can' tell the dfference between Walls and Tanks. The Radar Module cannot see Gifts."
        case .storageModule: return "Grants you a Storage Module. Storage Modules allow you to hold as much Fuel and Metal as you want, removing the maximum of 50. Additionally, Storage Modules can keep another module in reserve until you have space to install it. Furthermore, each storage module reduces Fuel Leakage by 50%."
        case .constructionModule: return "Grants you a Construction Module. Construction modules let you build Walls and Gifts."
        case .spyModule: return "Grants you a Spy Module. Spy modules let you see information about tanks around you."
        case .droneModule: return "Grants you a Drone Module. Drone modules let you control a surveilence drone"
        case .conduitModule: return "Grants you a Conduit Module. Conduit Modules allow you to equip an additional Module."
        case .challenger: return "You may issue a Challenge to another player. A Challenge is a competition of your choice adjudicated directly by the Game Operator. Examples include a chess match, a basketball 1v1, or a game of rock-paper-scissors. They may decline or accept the Challenge. You should clear up the terms with your challengee in advance as if they decline, you lose this card. Make sure to write the Challenge on the back of this card. The winner of the Challenge gains 20 Fuel and 20 Metal. The loser of the challenge loses 10 Fuel and 10 Metal. You and your challengee do NOT need to have 10 Fuel or Metal ahead of time; losing would simply put you into debt."
        case .moonDeerStew: return "Using this card feeds Moon Deer Stew to your entire crew. Once used, you have a 25% chance of receiving three random event cards. Otherwise, you do not recieve a status card on the next turn."
        }
    }
    
    var needsTankTarget: Bool {
        switch self {
        case .smite, .disruptor, .challenger: return true
        default: return false
        }
    }
    
    func preExecute(by tank: UnsafeMutablePointer<Tank>, target: UnsafeMutablePointer<any BoardObject>? = nil) { // Runs before turn.
        switch self {
            case .meteorite:
                tank.pointee.metal += 10
                return
            case .boost:
                tank.pointee.health += 10
                return
            case .meteorShower:
                for object in Game.shared.board.objects {
                    if let targetTank = object as? Tank {
                        if targetTank.coordinates.distanceTo(tank.pointee.coordinates) > 10 { continue }
                        targetTank.metal += 10
                    }
                }
                return
            case .storm:
                for object in Game.shared.board.objects {
                    if let targetTank = object as? Tank {
                        if targetTank.coordinates.distanceTo(tank.pointee.coordinates) > 10 { continue }
                        targetTank.health -= 10
                    }
                }
                return
            case .smite:
                target?.pointee.health -= 10
            case .disruptor:
                Game.shared.notes.append("Do not deliver a Status Card to \((target!.pointee as! Player).playerInfo.fullName)! They were Disrupted by \(tank.pointee.playerInfo.fullName).")
            case .radarModule:
                tank.pointee.modules.append(.radar)
                return
            case .storageModule:
                tank.pointee.modules.append(.storage)
                return
            case .constructionModule:
                tank.pointee.modules.append(.construction)
                return
            case .spyModule:
                tank.pointee.modules.append(.spy)
                return
            case .droneModule:
                tank.pointee.modules.append(.drone)
                return
            case .conduitModule:
                tank.pointee.modules.append(.conduit)
                return
            case .challenger: #warning("Rework Challenger rewards")
                tank.pointee.metal += 20
                (target!.pointee as! Tank).metal -= 10
            case .moonDeerStew:
                if Int.random(in: 0...3) == 0 {
                    for _ in 1...3 {
                        let card = Self.init()
                        Game.shared.eventCardsToPrint.append(card)
                        Game.shared.notes.append("Give \(tank.pointee.playerInfo.fullName) the \(card.name) Event Card.")
                    }
                } else {
                    Game.shared.notes.append("Do not deliver a Status Card to \(tank.pointee.playerInfo.fullName)! They ate Moon Deer Stew!")
                }
        }
    }
    
    func postExecute(by tank: Tank) { // Runs after turn. Allows for temporary boosts in stats like MovementRange.
        switch self {
        case .meteorite: return
        case .boost: return
        case .meteorShower: return
        case .storm: return
        case .smite: return
        case .disruptor: return
        case .radarModule: return
        case .storageModule: return
        case .constructionModule: return
        case .spyModule: return
        case .droneModule: return
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
