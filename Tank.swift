//  Tank.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/6/24.
//
//  Defines all tank types and attributes
import SwiftUI

func power(base: Double, exponent: Int) -> Double {
    var value = 1.0
    if exponent == 0 {
        return 1
    }
    for _ in 1...exponent {
        value *= base
    }
    return value
}

protocol Player {
    var playerDemographics: PlayerDemographics { get }
}

struct PlayerDemographics {
    let firstName: String
    let lastName: String
    let deliveryBuilding: String // Should be North, Virginia, or Lingle halls
    let deliveryType: String // Should be "locker" for North Hall, "room", or a house name for Lingle.
    let deliveryNumber: String // Should be a Locker Number or Room Number
    let virtualDelivery: String? // Should be an email adress
    let kills: Int //TODO: Move this value elsewhere
    
    func savedText() -> String {
        "p(\"\(firstName)\",\"\(lastName)\",\"\(deliveryBuilding)\",\"\(deliveryType)\",\"\(deliveryNumber)\",\(kills))"
    }
}

class Action {
    var tank: Tank
    
    enum ActionType {
        case move([Direction])
        case fire([Direction])
        case placeWall(Direction)
        case upgrade(UpgradeType)
        
        enum UpgradeType {
            case movementCost
            case movementRange
            case gunRange
            case gunDamage
            case gunCost
            case highDetailSightRange
            case lowDetailSightRange
            case radarRange
            case repair
        }
    }
    let type: ActionType
    
    init(_ type: ActionType, tank: Tank) {
        self.type = type
        self.tank = tank
    }
    
    func isAlowed() -> Bool {
        if self.fuelCost() > tank.fuel {
            return false
        }
        if self.metalCost() > tank.metal {
            return false
        }
        return true
    }
    
    func fuelCost() -> Int {
        switch type {
        case .move:
            return tank.movementCost
        case .fire:
            return tank.gunCost
        case .placeWall:
            return 0
        case .upgrade:
            return 0
        }
    }
    
    func metalCost() -> Int {
        switch type {
        case .move:
            return 0
        case .fire:
            return 0
        case .placeWall:
            return 5
        case .upgrade(let upgradeType):
            switch upgradeType {
            case .movementCost:
                return Int(power(base: Double(tank.movementCost), exponent: 1) * 1.5 + 0)
            case .movementRange:
                return Int(power(base: Double(tank.movementRange), exponent: 2) * 1 + 0)
            case .gunRange:
                return Int(power(base: Double(tank.gunRange), exponent: 2) * 1 + 1)
            case .gunDamage:
                return Int(power(base: Double(tank.gunDamage), exponent: 1) * 0.2 + 1)
            case .gunCost:
                return Int(power(base: Double(tank.gunCost), exponent: 1) * 1.5 + 0)
            case .highDetailSightRange:
                return Int(power(base: Double(tank.highDetailSightRange), exponent: 1) * 3 + 0)
            case .lowDetailSightRange:
                return Int(power(base: Double(tank.lowDetailSightRange), exponent: 1) * 2 + 0)
            case .radarRange:
                return Int(power(base: Double(tank.radarRange), exponent: 1) * 1 + 0)
            case .repair:
                return 3
            }
        }
    }
    
    func run() {
        if self.isAlowed() {
            switch type {
            case .move(let directions):
                tank.fuel -= self.fuelCost()
                tank.move(directions)
            case .fire(let directions):
                tank.fuel -= self.fuelCost()
                tank.fire(directions)
            case .placeWall(let direction):
                tank.metal -= self.metalCost()
                tank.placeWall(direction)
            case .upgrade(let upgradeType):
                switch upgradeType {
                case .movementCost:
                    tank.metal -= self.metalCost()
                    tank.movementCost -= 1
                case .movementRange:
                    tank.metal -= self.metalCost()
                    tank.movementRange += 1
                case .gunRange:
                    tank.metal -= self.metalCost()
                    tank.gunRange += 1
                case .gunDamage:
                    tank.metal -= self.metalCost()
                    tank.gunDamage += 5
                case .gunCost:
                    tank.metal -= self.metalCost()
                    tank.gunCost -= 1
                case .highDetailSightRange:
                    tank.metal -= self.metalCost()
                    tank.highDetailSightRange += 1
                case .lowDetailSightRange:
                    tank.metal -= self.metalCost()
                    tank.lowDetailSightRange += 1
                case .radarRange:
                    tank.metal -= self.metalCost()
                    tank.radarRange += 1
                case .repair:
                    tank.metal -= self.metalCost()
                    tank.health = min(100, tank.health + 5)
                }
            }
            for deadTank in game.board.objects.filter({ $0 is DeadTank }) as! [DeadTank] {
                if game.board.objects[deadTank.killedByIndex].id == tank.id {
                    deadTank.energy += 1
                }
            }
        }
    }
}

class Tank: BoardObject {
    var fuelDropped: Int
    var metalDropped: Int
    
    var appearance: Appearance
    var coordinates: Coordinates?
    
    var health: Int
    var defense: Int
    
    var playerDemographics: PlayerDemographics
    var dailyMessage: String
    
    var fuel: Int
    var metal: Int
    
    var movementCost: Int
    var movementRange: Int
    
    var gunRange: Int
    var gunDamage: Int
    var gunCost: Int
    
    var highDetailSightRange: Int
    var lowDetailSightRange: Int
    var radarRange: Int
    
    var virtualDelivery: String? // `nil` signifies standard delivery only. Should be a valid email address.
    
    init(
        appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics
    ) {
        self.playerDemographics = playerDemographics
        self.dailyMessage = ""
        self.fuel = 10
        self.metal = 5
        
        self.fuelDropped = 10
        self.metalDropped = 5
        
        self.movementCost = 10
        self.movementRange = 1
        
        self.gunRange = 1
        self.gunDamage = 5
        self.gunCost = 10
        
        self.highDetailSightRange = 1
        self.lowDetailSightRange = 2
        self.radarRange = 3
        
        self.virtualDelivery = nil
        self.health = 100
        self.defense = 0
        
        self.appearance = appearance
        self.coordinates = coordinates
    }
    
    init(
        appearance: Appearance,
        coordinates: Coordinates,
        playerDemographics: PlayerDemographics,
    
        fuel: Int,
        metal: Int,
        health: Int,
        defense: Int,
        
        movementCost: Int,
        movementRange: Int,
        
        gunRange: Int,
        gunDamage: Int,
        gunCost: Int,
        
        highDetailSightRange: Int,
        lowDetailSightRange: Int,
        radarRange: Int,
        
        dailyMessage: String,
    ) {
        self.fuel = fuel
        self.metal = metal
        self.fuelDropped = fuel
        self.metalDropped = metal
        self.movementCost = movementCost
        self.movementRange = movementRange
        self.gunRange = gunRange
        self.gunDamage = gunDamage
        self.gunCost = gunCost
        self.highDetailSightRange = highDetailSightRange
        self.lowDetailSightRange = lowDetailSightRange
        self.radarRange = radarRange
        self.playerDemographics = playerDemographics
        self.dailyMessage = dailyMessage
        self.health = health
        self.defense = defense
        self.appearance = appearance
        self.coordinates = coordinates
    }
    
    func formattedDailyMessage() -> String {
        var words = dailyMessage.split(separator: " ")
        var rows: [String] = []
        for row in 0...24 {
            let rowMaxLength = Int(Double(25 - row) * 2 - 10.0)
            if words.isEmpty {
                break
            }
            rows.append(" ")
            while rowMaxLength > rows[row].count + (words.first?.count ?? 9999999) {
                rows[row] = "\(words.removeLast()) \(rows[row])"
            }
            rows[row] = " " + rows[row]
        }
        return rows.reversed().joined(separator: "\n") + ["\n"]
    }
    
    func move(_ direction: [Direction]) {
        if direction.count <= movementRange {
            for step in direction {
                coordinates!.x += step.changeInXValue()
                coordinates!.y += step.changeInYValue()
                if(!coordinates!.inBounds()) {
                    coordinates!.x -= step.changeInXValue()
                    coordinates!.y -= step.changeInYValue()
                    health -= 10
                    return
                }
                for tile in game.board.objects {
                    if tile.coordinates == coordinates && tile.id != id {
                        if tile is Gift {
                            metal += tile.metalDropped
                            fuel += tile.fuelDropped
                            tile.health = 0
                        } else if tile is DeadTank {
                            continue
                        } else {
                            coordinates!.x -= step.changeInXValue()
                            coordinates!.y -= step.changeInYValue()
                            health -= 10
                            tile.health -= 10
                            return
                        }
                    }
                }
            }
        }
    }
    
    func fire(_ direction: [Direction]) {
        var bulletPosition: Coordinates = coordinates!
        for step in direction {
            bulletPosition.x += step.changeInXValue()
            bulletPosition.y += step.changeInYValue()
            for tileIndex in game.board.objects.indices {
                if game.board.objects[tileIndex].coordinates == bulletPosition {
                    game.board.objects[tileIndex].health -= (gunDamage - game.board.objects[tileIndex].defense)
                }
            }
        }
    }
    
    func placeWall(_ direction: Direction) {
        let wallCoordinates = Coordinates(x: coordinates!.x + direction.changeInXValue(), y: coordinates!.y + direction.changeInYValue(), level: coordinates!.level)
        for tile in game.board.objects {
            if tile.coordinates == wallCoordinates {
                return
            }
        }
        game.board.objects.append(Wall(coordinates: wallCoordinates))
    }
}

class DeadTank: BoardObject {
    var fuelDropped: Int = 0
    var metalDropped: Int = 0
    
    let appearance: Appearance
    var coordinates: Coordinates? = nil
    
    var health: Int = 0
    var defense: Int = 0
    
    var killedByIndex: Int //TODO: Use UUIDs instead of Indicies
    var playerDemographics: PlayerDemographics
    var dailyMessage: String
    
    var essence: Int
    var energy: Int
    
    var virtualDelivery: String?
    
    func placeWall(_ direction: [Direction]) {
        var coordinates = game.board.objects[killedByIndex].coordinates
        if direction.count <= energy {
            for step in direction {
                coordinates!.x += step.changeInXValue()
                coordinates!.y += step.changeInYValue()
                if(!coordinates!.inBounds()) {
                    return
                }
                for tile in game.board.objects {
                    if (tile.coordinates == coordinates) && !(AnyBoardObject(tile) == AnyBoardObject(self)) {
                        if tile is Gift {
                            tile.health = 0
                        }
                    }
                }
                game.board.objects.append(Wall(coordinates: coordinates!))
            }
        }
    }
    
    func placeGift(_ direction: [Direction]) {
        var coordinates = game.board.objects[killedByIndex].coordinates
        if direction.count <= Int(energy / 2) {
            for step in direction {
                coordinates!.x += step.changeInXValue()
                coordinates!.y += step.changeInYValue()
                if(!coordinates!.inBounds()) {
                    return
                }
                for tile in game.board.objects {
                    if (tile.coordinates == coordinates) && !(AnyBoardObject(tile) == AnyBoardObject(self)) {
                        if tile is Gift {
                            tile.health = 0
                        }
                    }
                }
                game.board.objects.append(Gift(coordinates: coordinates!, fuelReward: 10, metalReward: 10))
            }
        }
    }
    
    func harmTank(_ direction: [Direction]) {
        var coordinates = game.board.objects[killedByIndex].coordinates
        if direction.count <= Int(energy - 2) {
            for step in direction {
                coordinates!.x += step.changeInXValue()
                coordinates!.y += step.changeInYValue()
                if(!coordinates!.inBounds()) {
                    return
                }
                for tile in game.board.objects {
                    if (tile.coordinates == coordinates) && !(AnyBoardObject(tile) == AnyBoardObject(self)) {
                        if tile is Tank {
                            tile.health -= 10
                            tile.health = max(1, tile.health)
                        }
                    }
                }
            }
        }
    }
    
    func formattedDailyMessage() -> String {
        var words = dailyMessage.split(separator: " ")
        var rows: [String] = []
        for row in 0...24 {
            let rowMaxLength = Int(Double(25 - row) * 2 - 10.0)
            if words.isEmpty {
                break
            }
            rows.append(" ")
            while rowMaxLength > rows[row].count + (words.first?.count ?? 9999999) {
                rows[row] = "\(words.removeLast()) \(rows[row])"
            }
        }
        return rows.reversed().joined(separator: "\n") + ["\n"]
    }
    
    func description() -> String {
        if game.board.objects[killedByIndex] is Tank {
            return "killed by \((game.board.objects[killedByIndex] as! Tank).playerDemographics.firstName) \((game.board.objects[killedByIndex] as! Tank).playerDemographics.lastName), who currently has \((game.board.objects[killedByIndex] as! Tank).fuel)􀵞, \((game.board.objects[killedByIndex] as! Tank).metal)􀇷, \((game.board.objects[killedByIndex] as! Tank).health)􀞽, and \((game.board.objects[killedByIndex] as! Tank).defense)􀙨.)"
        }
        return "killed by \((game.board.objects[killedByIndex] as! DeadTank).playerDemographics.firstName) \((game.board.objects[killedByIndex] as! DeadTank).playerDemographics.lastName), who currently is currently dead, has \((game.board.objects[killedByIndex] as! DeadTank).essence)􀆿,  \((game.board.objects[killedByIndex] as! DeadTank).energy)􀋥, and was \((game.board.objects[killedByIndex] as! DeadTank).description())" 
    }
    
    init(
        appearance: Appearance, killedByIndex: Int, playerDemographics: PlayerDemographics, dailyMessage: String, essence: Int, energy: Int, _ virtualDelivery: String?) {
            self.killedByIndex = killedByIndex
            self.essence = essence
            self.energy = energy
            self.playerDemographics = playerDemographics
            self.dailyMessage = dailyMessage
            self.virtualDelivery = virtualDelivery
            self.appearance = appearance
        }
    
    init(_ tank: Tank, _ killedByIndex: Int) {
        let essenceEarned = { //TODO: Make this calculation less awful and account for new mechanics.
            var amount: Int = 0
            amount += Int(power(base: 1, exponent: tank.movementCost) * 1.5 + 0)
            amount += Int(power(base: 2, exponent: tank.movementRange) * 1 + 0)
            amount += Int(power(base: 2, exponent: tank.gunRange) * 1 + 1)
            amount += Int(power(base: 1, exponent: tank.gunDamage) * 1 + 1)
            amount += Int(power(base: 1, exponent: tank.gunCost) * 1.5 + 0)
            amount += Int(power(base: 1, exponent: tank.highDetailSightRange) * 3 + 0)
            amount += Int(power(base: 1, exponent: tank.lowDetailSightRange) * 2 + 0)
            amount += Int(power(base: 1, exponent: tank.radarRange) * 1 + 0)
            amount += 20 * tank.playerDemographics.kills
            amount += Int(tank.fuel / 3)
            amount += Int(tank.metal / 3)
            amount += Int(tank.defense)
            return Int(amount / 12)
        }
        self.killedByIndex = killedByIndex
        self.playerDemographics = tank.playerDemographics
        self.dailyMessage = "You have died. Your achievemnts in life have been added together to grant you \(essenceEarned()) essence. You will now only recieve your status cards on Mortuus Mondays. As a dead tank you have two main currencies: Essesnce and Energy. Essence, as rementioned, is given by your achievements in your previous lifetime. Energy is given to you periodically." //TODO: This text might need changing with new mechanics
        self.virtualDelivery = tank.virtualDelivery
        self.appearance = tank.appearance
        self.essence = essenceEarned()
        self.energy = 1
    }
}

class DeadAction {
    var tank: DeadTank
    
    enum ActionType {
        case placeWall([Direction])
        case placeGift([Direction])
        case harmTank([Direction])
        case burnEssence
        case channelEnergy
    }
    let type: ActionType
    
    init(_ type: ActionType, tank: DeadTank) {
        self.type = type
        self.tank = tank
    }
    
    func isAlowed() -> Bool {
        if self.essenceCost() > tank.essence {
            return false
        }
        if self.energyCost() > tank.energy {
            return false
        }
        return true
    }
    
    func essenceCost() -> Int {
        switch type {
        case .placeWall:
            return 1
        case .placeGift:
            return 3
        case .harmTank:
            return 0
        case .burnEssence:
            return 2
        case .channelEnergy:
            return -1
        }
    }
    
    func energyCost() -> Int {
        switch type {
        case .placeWall(let directions):
            return directions.count
        case .placeGift(let directions):
            return directions.count * 2
        case .harmTank:
            return 5
        case .burnEssence:
            return -1
        case .channelEnergy:
            return 2
        }
    }
    
    func run() {
        if self.isAlowed() {
            tank.essence -= essenceCost()
            tank.energy -= energyCost()
            switch type {
            case .placeWall(let directions):
                tank.placeWall(directions)
            case .placeGift(let directions):
                tank.placeGift(directions)
            case .harmTank(let directions):
                tank.harmTank(directions)
            default:
                let _ = ""
            }
        }
    }
}
