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

protocol Player: BoardObject {
    var playerDemographics: PlayerDemographics { get }
    var doVirtualDelivery: Bool { get }
}

struct AccessibilitySettings: Codable {
    var highContrast: Bool
    var colorblind: Bool
    var largeText: Bool
    
    init() {
        self.highContrast = false
        self.colorblind = false
        self.largeText = false
    }
}

struct PlayerDemographics: Codable {
    let firstName: String
    let lastName: String
    let deliveryBuilding: String // Should be North, Virginia, or Lingle halls
    let deliveryType: String // Should be "locker" for North Hall, "room", or a house name for Lingle.
    let deliveryNumber: String // Should be a Locker Number or Room Number
    let virtualDelivery: String? // Should be an email adress
    let accessibilitySettings: AccessibilitySettings
    let kills: Int //MARK: Move this value elsewhere
}

class Action {
    let tankId: UUID
    let precedence: Int
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
            case repair
        }
    }
    let type: ActionType
    
    init(_ type: ActionType, tank: Tank, precedence: Int) {
        self.type = type
        self.tankId = tank.uuid
        self.precedence = precedence
    }
    
    func isAlowed() -> Bool {
        let tank = game.board.objects.first(where: { $0.uuid == self.tankId }) as! Tank
        if self.fuelCost() > tank.fuel {
            return false
        }
        if self.metalCost() > tank.metal {
            return false
        }
        return true
    }
    
    func fuelCost() -> Int {
        let tank = game.board.objects.first(where: { $0.uuid == self.tankId }) as! Tank
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
        let tank = game.board.objects.first(where: { $0.uuid == self.tankId }) as! Tank
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
            case .repair:
                return 3
            }
        }
    }
}

class Tank: BoardObject, Player {
    override var type: BoardObjectType { .tank }
    
    var playerDemographics: PlayerDemographics
    
    var fuel: Int
    var metal: Int
    
    var movementCost: Int
    var movementRange: Int
    
    var gunRange: Int
    var gunDamage: Int
    var gunCost: Int
    
    var modules: [Module]
    
    var doVirtualDelivery: Bool
    
    enum CodingKeys: String, CodingKey {
        case playerDemographics, fuel, metal, movementCost, movementRange,
             gunRange, gunDamage, gunCost, modules, doVirtualDelivery, uuid
    }
    
    init(
        appearance: Appearance,
        coordinates: Coordinates,
        playerDemographics: PlayerDemographics
    ) {
        self.playerDemographics = playerDemographics
        self.fuel = 20
        self.metal = 20
        self.movementCost = 10
        self.movementRange = 1
        self.gunRange = 1
        self.gunDamage = 5
        self.gunCost = 10
        self.doVirtualDelivery = false
        self.modules = [TutorialModule(isWeekTwo: false)]
        super.init(fuelDropped: 20, metalDropped: 20, appearance: appearance, coordinates: coordinates, health: 100, defense: 0, uuid: UUID())
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
        modules: [Module],
        uuid: UUID?
    ) {
        self.fuel = fuel
        self.metal = metal
        self.movementCost = movementCost
        self.movementRange = movementRange
        self.gunRange = gunRange
        self.gunDamage = gunDamage
        self.gunCost = gunCost
        self.playerDemographics = playerDemographics
        self.doVirtualDelivery = false
        self.modules = modules
        super.init(fuelDropped: fuel, metalDropped: metal, appearance: appearance, coordinates: coordinates, health: health, defense: defense, uuid: uuid ?? UUID())
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.playerDemographics = try container.decode(PlayerDemographics.self, forKey: .playerDemographics)
        self.fuel = try container.decode(Int.self, forKey: .fuel)
        self.metal = try container.decode(Int.self, forKey: .metal)
        self.movementCost = try container.decode(Int.self, forKey: .movementCost)
        self.movementRange = try container.decode(Int.self, forKey: .movementRange)
        self.gunRange = try container.decode(Int.self, forKey: .gunRange)
        self.gunDamage = try container.decode(Int.self, forKey: .gunDamage)
        self.gunCost = try container.decode(Int.self, forKey: .gunCost)
        self.doVirtualDelivery = try container.decode(Bool.self, forKey: .doVirtualDelivery)
        
        
        var modulesArray = try container.nestedUnkeyedContainer(forKey: .modules)
        var modules: [Module] = []
        
        while !modulesArray.isAtEnd {
            let moduleDecoder = try modulesArray.superDecoder()
            let module = try Module.decode(from: moduleDecoder) // <-- Factory method
            modules.append(module)
        }
        
        self.modules = modules.filter({ $0 is ConduitModule }) + modules.filter({ !($0 is ConduitModule) }) //sorts modules with conduits first to avoid nesting Conduits.
        
        try super.init(from: decoder)
        
        for module in self.modules {
            module.tankId = self.uuid
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerDemographics, forKey: .playerDemographics)
        try container.encode(fuel, forKey: .fuel)
        try container.encode(metal, forKey: .metal)
        try container.encode(movementCost, forKey: .movementCost)
        try container.encode(movementRange, forKey: .movementRange)
        try container.encode(gunRange, forKey: .gunRange)
        try container.encode(gunDamage, forKey: .gunDamage)
        try container.encode(gunCost, forKey: .gunCost)
        try container.encode(doVirtualDelivery, forKey: .doVirtualDelivery)
        
        var arrayContainer = container.nestedUnkeyedContainer(forKey: .modules)

        for module in modules {
            try module.encode(to: arrayContainer.superEncoder())
        }
    }
    
    func move(_ direction: [Direction]) {
        if direction.count <= movementRange {
            for step in direction {
                coordinates!.x += step.changeInXValue()
                coordinates!.y += step.changeInYValue()
                if !coordinates!.inBounds() {
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
    
    func constrainFuelAndMetal() {
        if modules.contains(where: { $0 is StorageModule }) {
            return
        } else {
            fuel = min(fuel, 50)
            metal = min(metal, 50)
        }
    }
}

class DeadTank: BoardObject, Player {
    override var type: BoardObjectType { .deadTank }
    
    var killedByIndex: Int
    var playerDemographics: PlayerDemographics
    var essence: Int
    var energy: Int
    var doVirtualDelivery: Bool
    
    enum CodingKeys: String, CodingKey {
        case killedByIndex, playerDemographics, essence, energy, doVirtualDelivery
    }
    
    init(
        appearance: Appearance,
        killedByIndex: Int,
        playerDemographics: PlayerDemographics,
        dailyMessage: String,
        essence: Int,
        energy: Int,
        doVirtualDelivery: Bool?,
        uuid: UUID?
    ) {
        self.killedByIndex = killedByIndex
        self.essence = essence
        self.energy = energy
        self.playerDemographics = playerDemographics
        self.doVirtualDelivery = doVirtualDelivery ?? false
        super.init(fuelDropped: 0, metalDropped: 0, appearance: appearance, coordinates: nil, health: 0, defense: 0, uuid: uuid ?? UUID())
    }
    
    init(_ tank: Tank, _ killedByIndex: Int) {
        let essenceEarned = {
            var amount = 0
            amount += Int(power(base: 1, exponent: tank.movementCost) * 1.5)
            amount += Int(power(base: 2, exponent: tank.movementRange))
            amount += Int(power(base: 2, exponent: tank.gunRange))
            amount += Int(power(base: 1, exponent: tank.gunDamage))
            amount += Int(power(base: 1, exponent: tank.gunCost) * 1.5)
            amount += 20 * tank.playerDemographics.kills
            amount += Int(tank.fuel / 3)
            amount += Int(tank.metal / 3)
            amount += Int(tank.defense)
            return Int(amount / 12)
        }
        self.killedByIndex = killedByIndex
        self.playerDemographics = tank.playerDemographics
        self.doVirtualDelivery = tank.doVirtualDelivery
        self.essence = essenceEarned()
        self.energy = 1
        super.init(fuelDropped: 0, metalDropped: 0, appearance: tank.appearance, coordinates: nil, health: 0, defense: 0, uuid: tank.uuid)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.killedByIndex = try container.decode(Int.self, forKey: .killedByIndex)
        self.playerDemographics = try container.decode(PlayerDemographics.self, forKey: .playerDemographics)
        self.essence = try container.decode(Int.self, forKey: .essence)
        self.energy = try container.decode(Int.self, forKey: .energy)
        self.doVirtualDelivery = try container.decode(Bool.self, forKey: .doVirtualDelivery)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(killedByIndex, forKey: .killedByIndex)
        try container.encode(playerDemographics, forKey: .playerDemographics)
        try container.encode(essence, forKey: .essence)
        try container.encode(energy, forKey: .energy)
        try container.encode(doVirtualDelivery, forKey: .doVirtualDelivery)
    }
    
    func placeWall(_ direction: [Direction]) {
        var coordinates = game.board.objects[killedByIndex].coordinates!
        if direction.count <= energy {
            for step in direction {
                coordinates.x += step.changeInXValue()
                coordinates.y += step.changeInYValue()
                if !coordinates.inBounds() { return }
                game.board.objects.append(Wall(coordinates: coordinates))
            }
        }
    }
    
    func placeGift(_ direction: [Direction]) {
        var coordinates = game.board.objects[killedByIndex].coordinates!
        if direction.count <= Int(energy / 2) {
            for step in direction {
                coordinates.x += step.changeInXValue()
                coordinates.y += step.changeInYValue()
                if !coordinates.inBounds() { return }
                game.board.objects.append(Gift(coordinates: coordinates))
            }
        }
    }
    
    func harmTank(_ direction: [Direction]) {
        var coordinates = game.board.objects[killedByIndex].coordinates!
        if direction.count <= Int(energy - 2) {
            for step in direction {
                coordinates.x += step.changeInXValue()
                coordinates.y += step.changeInYValue()
                if !coordinates.inBounds() { return }
                for tile in game.board.objects {
                    if tile.coordinates == coordinates, let target = tile as? Tank {
                        target.health -= 10
                        target.health = max(1, target.health)
                    }
                }
            }
        }
    }
    
    func description() -> String {
        if let killer = game.board.objects[killedByIndex] as? Tank {
            return "killed by \(killer.playerDemographics.firstName) \(killer.playerDemographics.lastName), who currently has \(killer.fuel)􀵞, \(killer.metal)􀇷, \(killer.health)􀞽, and \(killer.defense)􀙨."
        }
        if let killer = game.board.objects[killedByIndex] as? DeadTank {
            return "killed by \(killer.playerDemographics.firstName) \(killer.playerDemographics.lastName), who is dead, has \(killer.essence)􀆿, \(killer.energy)􀋥, and was \(killer.description())"
        }
        return "killed by natural causes."
    }
}


class DeadAction {
    var tank: DeadTank
    
    enum ActionType {
        case placeWall([Direction])
        case placeGift([Direction])
        case harmTank([Direction]) //MARK: Switch to Tank uuids for this action
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
            case .burnEssence:
                let _ = 0 //do nothing
                //price calculations fully complete this action
            case .channelEnergy:
                let _ = 0 //do nothing
                //price calculations fully complete this action
            }
        }
    }
}
