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
    var playerInfo: PlayerInfo { get set }
    func statusCardFront() -> AnyView
    func statusCardBack() -> AnyView
    func statusCardConduitFront() -> AnyView?
    func statusCardConduitBack() -> AnyView?
    func virtualStatusCard() -> AnyView
}

struct AccessibilitySettings: Codable, Equatable {
    let highContrast: Bool
    let colorblind: Bool
    let largeText: Bool
    
    mutating func highContrast(_ newValue: Bool) {
        self = .init(highContrast: newValue, colorblind: colorblind, largeText: largeText)
    }
    
    mutating func colorblind(_ newValue: Bool) {
        self = .init(highContrast: highContrast, colorblind: newValue, largeText: largeText)
    }
    
    mutating func largeText(_ newValue: Bool) {
        self = .init(highContrast: highContrast, colorblind: colorblind, largeText: newValue)
    }
    
    init() { //default "lazy" initializer for when no accessibility settings are needed
        self.highContrast = false
        self.colorblind = false
        self.largeText = false
    }
    
    init(highContrast: Bool, colorblind: Bool, largeText: Bool) { //regular initializer
        self.highContrast = highContrast
        self.colorblind = colorblind
        self.largeText = largeText
    }
}

struct PlayerInfo: Codable {
    let firstName: String
    let lastName: String
    let deliveryBuilding: String // Should be North, Virginia, or Lingle halls
    let deliveryType: String // Should be "locker" for North Hall, "room", or a house name for Lingle.
    let deliveryNumber: String // Should be a Locker Number or Room Number
    let virtualDelivery: String? // Should be an email adress
    let accessibilitySettings: AccessibilitySettings
    let kills: Int //MARK: Move this value elsewhere, maybe add a statistics system
    let doVirtualDelivery: Bool
    
    mutating func firstName(_ newValue: String) {
        self = .init(firstName: newValue, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func lastName(_ newValue: String) {
        self = .init(firstName: firstName, lastName: newValue, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func deliveryBuilding(_ newValue: String) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: newValue, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func deliveryType(_ newValue: String) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: newValue, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func deliveryNumber(_ newValue: String) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: newValue, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func virtualDelivery(_ newValue: String?) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: newValue, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func accessibilitySettings(_ newValue: AccessibilitySettings) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: newValue, kills: kills, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func kills(_ newValue: Int) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: newValue, doVirtualDelivery: doVirtualDelivery)
    }
    mutating func doVirtualDelivery(_ newValue: Bool) {
        self = .init(firstName: firstName, lastName: lastName, deliveryBuilding: deliveryBuilding, deliveryType: deliveryType, deliveryNumber: deliveryNumber, virtualDelivery: virtualDelivery, accessibilitySettings: accessibilitySettings, kills: kills, doVirtualDelivery: newValue)
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

class Tank: BoardObject, Player {
    static func bindModules() {
        for tank in Game.shared.board.objects.filter({ $0 is Tank} ) as! [Tank] {
            for module in tank.modules {
                module.tankId = tank.uuid
                if let droneModule = module as? DroneModule {
                    if droneModule.droneId == nil {
                        let uuid = UUID()
                        Game.shared.board.objects.append(Drone(coordinates: Coordinates.init(x: Int.random(in: -10...10), y: Int.random(in: -10...10)), uuid: uuid))
                        droneModule.droneId = uuid
                    }
                }
            }
        }
    }
    
    override var type: BoardObjectType { .tank }
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
    var playerInfo: PlayerInfo
    
    var fuel: Int
    var metal: Int
    
    var movementCost: Int
    var movementRange: Int
    
    var gunRange: Int
    var gunDamage: Int
    var gunCost: Int
    
    var modules: [Module]
    
    var equippedConduitModules: Int {
            return min(modules.filter{ $0 is ConduitModule }.count, 2)
    }
    
    var equippedStorageModules: Int {
            return displayedModules.filter{ $0 is StorageModule }.count
    }
    
    var displayedModules: [Module] {
        var displayedModules: [Module] = []
        var displayableModules: [Module] = modules.filter({ !($0 is ConduitModule) })
           
        for _ in 0...(1 + equippedConduitModules) {
            if displayableModules.isEmpty { break }
            displayedModules.append(displayableModules.removeFirst())
        }
        return displayedModules
    }
    
    var nonDisplayedModules: [Module] {
        var workingModules = modules.filter({ !($0 is ConduitModule) })
        if workingModules.count < 2 + equippedConduitModules {
            return []
        }
        workingModules.removeFirst()
        workingModules.removeFirst()
        if equippedConduitModules >= 1 {
            workingModules.removeFirst()
        }
        if equippedConduitModules >= 2 {
            workingModules.removeFirst()
        }
        return workingModules
    }
    
    var hasTooManyModules: Bool {
        if nonDisplayedModules.count > equippedStorageModules { return true }
        return false
    }
    
    enum CodingKeys: String, CodingKey {
        case playerInfo, fuel, metal, movementCost, movementRange,
             gunRange, gunDamage, gunCost, modules, uuid
    }
    
    init(
        appearance: Appearance,
        coordinates: Coordinates,
        playerInfo: PlayerInfo
    ) {
        self.playerInfo = playerInfo
        self.fuel = 20
        self.metal = 20
        self.movementCost = 10
        self.movementRange = 1
        self.gunRange = 1
        self.gunDamage = 5
        self.gunCost = 10
        self.modules = [TutorialModule(isWeekTwo: false)]
        super.init(fuelDropped: 20, metalDropped: 20, appearance: appearance, coordinates: coordinates, health: 100, defense: 0, uuid: UUID())
    }
    
    init(
        appearance: Appearance,
        coordinates: Coordinates,
        playerInfo: PlayerInfo,
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
        self.playerInfo = playerInfo
        self.modules = modules
        super.init(fuelDropped: fuel, metalDropped: metal, appearance: appearance, coordinates: coordinates, health: health, defense: defense, uuid: uuid ?? UUID())
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.playerInfo = try container.decode(PlayerInfo.self, forKey: .playerInfo)
        self.fuel = try container.decode(Int.self, forKey: .fuel)
        self.metal = try container.decode(Int.self, forKey: .metal)
        self.movementCost = try container.decode(Int.self, forKey: .movementCost)
        self.movementRange = try container.decode(Int.self, forKey: .movementRange)
        self.gunRange = try container.decode(Int.self, forKey: .gunRange)
        self.gunDamage = try container.decode(Int.self, forKey: .gunDamage)
        self.gunCost = try container.decode(Int.self, forKey: .gunCost)
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
        try container.encode(playerInfo, forKey: .playerInfo)
        try container.encode(fuel, forKey: .fuel)
        try container.encode(metal, forKey: .metal)
        try container.encode(movementCost, forKey: .movementCost)
        try container.encode(movementRange, forKey: .movementRange)
        try container.encode(gunRange, forKey: .gunRange)
        try container.encode(gunDamage, forKey: .gunDamage)
        try container.encode(gunCost, forKey: .gunCost)
        
        var arrayContainer = container.nestedUnkeyedContainer(forKey: .modules)

        for module in modules {
            try module.encode(to: arrayContainer.superEncoder())
        }
    }
    
    func move(_ vector: [Direction], _ rotation: Direction) { //does not subtract fuel
        for step in vector {
            coordinates?.rotation(step)
            coordinates?.moveBy(step)
            if !coordinates!.inBounds() {
                coordinates?.moveBy(step.opposite)
                health -= 10
                return
            }
            for tile in Game.shared.board.objects {
                if tile.coordinates == coordinates && tile.uuid != uuid {
                    if tile is Gift {
                        metal += tile.metalDropped
                        fuel += tile.fuelDropped
                        if (tile as! Gift).containedModule != nil {
                            modules.append((tile as! Gift).containedModule!)
                        }
                        Game.shared.board.objects.removeAll(where: { $0.uuid == tile.uuid })
                    } else if tile.isSolid {
                        coordinates?.moveBy(step.opposite)
                        health -= 10
                        tile.health -= 10
                        return
                    }
                }
            }
        }
        coordinates?.rotation(rotation)
    }
    
    func fire(_ direction: [Direction]) { //does not subtract fuel
        var bulletPosition: Coordinates = coordinates!
        for step in direction {
            bulletPosition.moveBy(step)
            for tile in Game.shared.board.objects {
                if tile.coordinates == bulletPosition {
                    if tile.isRigid { //pass over nonrigid objects
                        tile.health -= (gunDamage - tile.defense)
                        return
                    }
                }
            }
        }
        for tile in Game.shared.board.objects { //come back at the end to check for rigid objects only at final position.
            if tile.coordinates == bulletPosition {
                tile.health -= (gunDamage - tile.defense)
                return
            }
        }
    }
    
    func constrainToMaximumValues() {
        if displayedModules.contains(where: { $0 is StorageModule }) {} else {
            fuel = min(fuel, 50)
            metal = min(metal, 50)
        }
    }
    
    func statusCardBack() -> AnyView {
        return AnyView(StatusCardBack(tank: self))
    }
    func statusCardFront() -> AnyView {
        return AnyView(StatusCardFront(tank: self))
    }
    func statusCardConduitBack() -> AnyView? {
        if hasTooManyModules {
            return nil
        }
        if displayedModules.count < 4 { return nil }
        return AnyView(ModuleView(module: displayedModules[3]))
    }
    func statusCardConduitFront() -> AnyView? {
        if hasTooManyModules {
            return nil
        }
        if displayedModules.count < 3 { return nil }
        return AnyView(ModuleView(module: displayedModules[2]))
    }
    func virtualStatusCard() -> AnyView {
        return AnyView(VirtualStatusCard(tank: self))
    }
}

class DeadTank: BoardObject, Player {
    override var type: BoardObjectType { .deadTank }
    
    static var isSolid: Bool { false }
    static var isRigid: Bool { false }
    
    var killedByIndex: Int
    var playerInfo: PlayerInfo
    var essence: Int
    var energy: Int
    
    enum CodingKeys: String, CodingKey {
        case killedByIndex, playerInfo, essence, energy
    }
    
    init(
        appearance: Appearance,
        killedByIndex: Int,
        playerInfo: PlayerInfo,
        dailyMessage: String,
        essence: Int,
        energy: Int,
        doVirtualDelivery: Bool?,
        uuid: UUID?
    ) {
        self.killedByIndex = killedByIndex
        self.essence = essence
        self.energy = energy
        self.playerInfo = playerInfo
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
            amount += 20 * tank.playerInfo.kills
            amount += Int(tank.fuel / 3)
            amount += Int(tank.metal / 3)
            amount += Int(tank.defense)
            return Int(amount / 12)
        }
        self.killedByIndex = killedByIndex
        self.playerInfo = tank.playerInfo
        self.essence = essenceEarned()
        self.energy = 1
        super.init(fuelDropped: 0, metalDropped: 0, appearance: tank.appearance, coordinates: nil, health: 0, defense: 0, uuid: tank.uuid)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.killedByIndex = try container.decode(Int.self, forKey: .killedByIndex)
        self.playerInfo = try container.decode(PlayerInfo.self, forKey: .playerInfo)
        self.essence = try container.decode(Int.self, forKey: .essence)
        self.energy = try container.decode(Int.self, forKey: .energy)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(killedByIndex, forKey: .killedByIndex)
        try container.encode(playerInfo, forKey: .playerInfo)
        try container.encode(essence, forKey: .essence)
        try container.encode(energy, forKey: .energy)
    }
    
    func placeWall(_ direction: [Direction]) {
        var coordinates = Game.shared.board.objects[killedByIndex].coordinates!
        if direction.count <= energy {
            for step in direction {
                coordinates.moveBy(step)
                if !coordinates.inBounds() { return }
                Game.shared.board.objects.append(Wall(coordinates: coordinates))
            }
        }
    }
    
    func placeGift(_ direction: [Direction]) {
        var coordinates = Game.shared.board.objects[killedByIndex].coordinates!
        if direction.count <= Int(energy / 2) {
            for step in direction {
                coordinates.moveBy(step)
                if !coordinates.inBounds() { return }
                Game.shared.board.objects.append(Gift(coordinates: coordinates))
            }
        }
    }
    
    func harmTank(_ direction: [Direction]) {
        var coordinates = Game.shared.board.objects[killedByIndex].coordinates!
        if direction.count <= Int(energy - 2) {
            for step in direction {
                coordinates.moveBy(step)
                if !coordinates.inBounds() { return }
                for tile in Game.shared.board.objects {
                    if tile.coordinates == coordinates, let target = tile as? Tank {
                        target.health -= 10
                        target.health = max(1, target.health)
                    }
                }
            }
        }
    }
    
    func description() -> String {
        if let killer = Game.shared.board.objects[killedByIndex] as? Tank {
            return "killed by \(killer.playerInfo.firstName) \(killer.playerInfo.lastName), who currently has \(killer.fuel)􀵞, \(killer.metal)􀇷, \(killer.health)􀞽, and \(killer.defense)􀙨."
        }
        if let killer = Game.shared.board.objects[killedByIndex] as? DeadTank {
            return "killed by \(killer.playerInfo.firstName) \(killer.playerInfo.lastName), who is dead, has \(killer.essence)􀆿, \(killer.energy)􀋥, and was \(killer.description())"
        }
        return "killed by natural causes."
    }
    
    func statusCardBack() -> AnyView {
        return AnyView(DeadStatusCardBack(tank: self))
    }
    func statusCardFront() -> AnyView {
        return AnyView(DeadStatusCardFront(tank: self))
    }
    func statusCardConduitBack() -> AnyView? {
        return nil
    }
    func statusCardConduitFront() -> AnyView? {
        return nil
    }
    func virtualStatusCard() -> AnyView {
        fatalError("Dead Virtual Satus Card not implemented")
    }
}


class DeadAction { //MARK: revamp DeadActions
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
