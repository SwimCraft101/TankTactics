//
//  Action.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/27/25.
//

import Foundation

protocol SingleDirectionAction {
    var direction: Direction { get }
}

protocol MultiDirectionAction {
    var vector: [Direction] { get }
}

class TankAction: Identifiable {
    let tankId: UUID // The UUID of the Tank performing the Action
    let precedence: Int // The amount of Fuel spent on Precedence for the action
    var fuelCost: Int { 0 } /// __ _IMPORTANT:_ THE TANK FUEL COST DOES NOT INCLUDE THE VALUE OF PRECEDENCE, NOR THE VALUE SAVED ON TUESDAYS.__
    var metalCost: Int { 0 }
    
    var icon: String { fatalError("Base-class TankActions should never be rendered in this way.") }
    
    var tank: Tank {
        Game.shared.board.objects.first { $0.uuid == tankId } as! Tank
    }
    
    init(tankId: UUID, precedence: Int) {
        self.tankId = tankId
        self.precedence = precedence
    }
    
    var isAllowed: Bool {
        if tank.fuel < ((Game.shared.gameDay == .tuesday) ? Int(ceil(Double(fuelCost) / 2)) : fuelCost) + precedence { //halves and rounds up the fuel value on tuesdays
            return false
        }
        if tank.metal < metalCost {
            return false
        }
        return true
    }
    
    func execute() -> Bool {
        if isAllowed {
            tank.fuel -= ((Game.shared.gameDay == .tuesday) ? Int(ceil(Double(fuelCost) / 2)) : fuelCost)
            tank.metal -= metalCost
            tank.fuel -= precedence
            return true
        }
        print("The game attempted to execute an action not allowable! Tank: \(tank)")
        return false
    }
}

class Move: TankAction, MultiDirectionAction {
    override var fuelCost: Int { tank.movementCost }
    let vector: [Direction]
    let rotation: Direction
    
    override var icon: String { "righttriangle" }
    
    override var isAllowed: Bool {
        if super.isAllowed {
            if vector.count <= tank.movementRange {
                return true
            }
        }
        return false
    }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.move(vector, rotation)
            return true
        }
        return false
    }
    
    init(_ vector: [Direction], _ rotation: Direction, tankId: UUID, precedence: Int) {
        self.vector = vector
        self.rotation = rotation
        super.init(tankId: tankId, precedence: precedence)
    }
}

class Fire: TankAction, MultiDirectionAction {
    override var fuelCost: Int { tank.gunCost }
    let vector: [Direction]
    
    override var icon: String { "multiply" }
    
    override var isAllowed: Bool {
        if super.isAllowed {
            if vector.count <= tank.gunRange {
                return true
            }
        }
        return false
    }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.fire(vector)
            return true
        }
        return false
    }
    
    init(_ vector: [Direction], tankId: UUID, precedence: Int) {
        self.vector = vector
        super.init(tankId: tankId, precedence: precedence)
    }
}

class PurchaseModule: TankAction {
    override var metalCost: Int { Game.shared.moduleOfferPrice! }
    
    override var icon: String { "square.on.square.dashed" }
    
    override var isAllowed: Bool {
        if Game.shared.gameDay != .monday { return false }
        if super.isAllowed {
            return true
        }
        return false
    }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.modules.append(Game.shared.moduleOffered!)
            return true
        }
        return false
    }
    
    init(tankId: UUID) {
        super.init(tankId: tankId, precedence: 0)
    }
}

class BidForEventCard: TankAction {
    let fuelBid: Int
    let metalBid: Int
    
    override var fuelCost: Int { fuelBid }
    override var metalCost: Int { metalBid }
    
    override var icon: String { "text.document" }
    
    override var isAllowed: Bool {
        if super.isAllowed {
            if fuelBid <= tank.fuel {
                if metalBid <= tank.metal {
                    return true
                }
            }
        }
        return false
    }
    
    override func execute() -> Bool {
        if super.execute() {
            Game.shared.eventCardBidders.append((tank.uuid, fuelBid + metalBid))
            return true
        }
        return false
    }
    
    init(fuelBid: Int, metalBid: Int, tankId: UUID) {
        self.fuelBid = fuelBid
        self.metalBid = metalBid
        super.init(tankId: tankId, precedence: 0)
    }
}

class ExtractPhysicalFuelOrMetal: TankAction {
    let fuelToExtract: Int
    let metalToExtract: Int
    
    override var fuelCost: Int { fuelToExtract }
    override var metalCost: Int { metalToExtract }
    
    override var icon: String { "shippingbox" }
    
    override var isAllowed: Bool {
        if super.isAllowed {
            if fuelToExtract <= tank.fuel {
                if metalToExtract <= tank.metal {
                    return true
                }
            }
        }
        return false
    }
    
    override func execute() -> Bool {
        if super.execute() {
            //MARK: Add to Turn Report how many tokens to give each tank
            return true
        }
        return false
    }
    
    init(fuelToExtract: Int, metalToExtract: Int, tankId: UUID) {
        self.fuelToExtract = fuelToExtract
        self.metalToExtract = metalToExtract
        super.init(tankId: tankId, precedence: 0)
    }
}

class Upgrade: TankAction {}

class WednesdayUpgrade: Upgrade {
    override var isAllowed: Bool {
        if Game.shared.gameDay != .wednesday && !(tank.modules.contains(where: { $0 is FactoryModule })) { return false }
        if super.isAllowed {
            return true
        }
        return false
    }
    
    init(tankId: UUID) {
        super.init(tankId: tankId, precedence: 0)
    }
}

class UpgradeMovementRange: WednesdayUpgrade {
    override var metalCost: Int {
        return [
            0, //movementRange should never be zero, so this case should be unused
            10, //level 1 to level 2
            20, //level 2 to level 3
            40, //level 3 to level 4
            60, //level 4 to level 5
            70, //level 5 to level 6
            80, //level 6 to level 7
            90, //level 7 to level 8
            100, //level 8 to level 9
            110, //level 9 to level 10
            Int.max //there is no level 11
        ][tank.movementRange]
    }
    
    override var icon: String { "car.rear.road.lane.distance.3" }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.movementRange += 1
            return true
        }
        return false
    }
}

class UpgradeMovementCost: WednesdayUpgrade {
    override var metalCost: Int {
        return [
            Int.max, //there is no level 0
            100, //level 2 to level 1
            50, //level 3 to level 2
            30, //level 4 to level 3
            24, //level 5 to level 4
            20, //level 6 to level 5
            16, //level 7 to level 6
            12, //level 8 to level 7
            8, //level 9 to level 8
            5, //level 10 to level 9
            0 //movementCost should never be 11, so this case should be unused
        ][tank.movementCost]
    }
    
    override var icon: String { "gauge.with.dots.needle.50percent" }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.movementCost -= 1
            return true
        }
        return false
    }
}

class Thrift: TankAction {
    override var isAllowed: Bool {
        if Game.shared.gameDay != .thursday { return false }
        return super.isAllowed
    }
    
    override var icon: String { "storefront" }
    
    init(tankId: UUID) {
        super.init(tankId: tankId, precedence: 0) //All thrift Actions muct have no precedence
    }
}
    
class SellUpgrade: Thrift {
    var upgrade: Upgrade
    
    init(upgrade: Upgrade, tankId: UUID) {
        self.upgrade = upgrade
        super.init(tankId: tankId)
    }
    
    override func execute() -> Bool {
        if super.execute() {
            switch upgrade {
            case is UpgradeMovementCost:
                tank.movementCost += 1
                return true
            case is UpgradeMovementRange:
                tank.movementRange += 1
                return true
            case is UpgradeGunCost:
                tank.gunCost += 1
                return true
            case is UpgradeGunRange:
                tank.gunRange += 1
                return true
            case is UpgradeGunDamage:
                tank.gunDamage += 1
                return true
            default:
                fatalError("An invalid upgrade was passed to SellUpgrade: \(upgrade)")
            }
        }
        return false
    }
}

class SellModule: Thrift {
    var module: ModuleType
    
    override var metalCost: Int {
        switch module {
        case .radar: return -10 - Game.shared.randomSeed &* 219857 % 5
        case .storage: return -15 - Game.shared.randomSeed &* 219857 % 5
        case .drone: return -40 - Game.shared.randomSeed &* 219857 % 5
        case .spy: return -35 - Game.shared.randomSeed &* 219857 % 5
        case .conduit: return -45 - Game.shared.randomSeed &* 219857 % 5
        case .factory: return -20 - Game.shared.randomSeed &* 219857 % 5
        case .construction: return -10 - Game.shared.randomSeed &* 219857 % 5
        case .tutorial: return -10
        case .websitePlug: return -10
        case .module: return -10 - Game.shared.randomSeed &* 219857 % 5
        }
    }
    
    init(module: ModuleType, tankId: UUID) {
        self.module = module
        super.init(tankId: tankId)
    }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.modules.remove(at: tank.modules.firstIndex{ $0.type == module }!)
        }
        return false
    }
}

class FridayUpgrade: Upgrade {
    override var isAllowed: Bool {
        if Game.shared.gameDay != .friday && !(tank.modules.contains(where: { $0 is FactoryModule })) { return false }
        return super.isAllowed
    }
    
    init(tankId: UUID) {
        super.init(tankId: tankId, precedence: 0)
    }
}

class UpgradeGunRange: FridayUpgrade {
    override var metalCost: Int {
        return [
            0, //gunRange should never be zero, so this case should be unused
            10, //level 1 to level 2
            20, //level 2 to level 3
            40, //level 3 to level 4
            60, //level 4 to level 5
            70, //level 5 to level 6
            80, //level 6 to level 7
            90, //level 7 to level 8
            100, //level 8 to level 9
            110, //level 9 to level 10
            Int.max //there is no level 11
        ][tank.gunRange]
    }
    
    override var icon: String { "dot.scope" }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.gunRange += 1
            return true
        }
        return false
    }
}

class UpgradeGunCost: FridayUpgrade {
    override var metalCost: Int {
        return [
            Int.max, //there is no level 0
            100, //level 2 to level 1
            50, //level 3 to level 2
            30, //level 4 to level 3
            24, //level 5 to level 4
            20, //level 6 to level 5
            16, //level 7 to level 6
            12, //level 8 to level 7
            8, //level 9 to level 8
            5, //level 10 to level 9
            0  //gunCost should never be 11, so this case should be unused
        ][tank.gunCost]
    }
    
    override var icon: String { "bandage" }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.gunCost -= 1
            return true
        }
        return false
    }
}

class UpgradeGunDamage: FridayUpgrade {
    override var metalCost: Int {
        return [
            0, //gunDamage should never be zero, so this case should be unused
            10, //level 5 to level 10
            20, //level 10 to level 15
            40, //level 15 to level 20
            60, //level 20 to level 25
            70, //level 25 to level 30
            80, //level 30 to level 35
            90, //level 35 to level 40
            100, //level 40 to level 45
            110, //level 45 to level 50
            Int.max //there is no level 55
        ][tank.gunDamage]
    }
    
    override var icon: String { "chart.bar.xaxis" }
    
    override func execute() -> Bool {
        if super.execute() {
            tank.gunDamage += 5
            return true
        }
        return false
    }
}

class ConstructionAction: TankAction, SingleDirectionAction {
    var direction: Direction
    
    var destinationCoordinates: Coordinates {
        Coordinates(x: tank.coordinates!.x + direction.changeInXValue, y: tank.coordinates!.y + direction.changeInYValue, level: tank.coordinates!.level)
    }
    
    override var isAllowed: Bool {
        if super.isAllowed {
            if tank.modules.contains(where: { $0 is ConstructionModule }) {
                for object in Game.shared.board.objects {
                    if object is Gift { continue }
                    if object is DeadTank { continue }
                    if object.coordinates == destinationCoordinates {
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
    
    init(direction: Direction, tankId: UUID, precedence: Int) {
        self.direction = direction
        super.init(tankId: tankId, precedence: precedence)
    }
}

class BuildWall: ConstructionAction {
    override var metalCost: Int { 5 }
    
    override func execute() -> Bool {
        if super.execute() {
            Game.shared.board.objects.append(Wall(coordinates: destinationCoordinates))
        }
        return false
    }
    
    override var icon: String { "square" }
}

class BuildReinforcedWall: ConstructionAction {
    override var metalCost: Int { 20 }
    
    override func execute() -> Bool {
        if super.execute() {
            Game.shared.board.objects.append(ReinforcedWall(coordinates: destinationCoordinates))
        }
        return false
    }
    
    override var icon: String { "lock.fill" }
}

class BuildGift: ConstructionAction {
    var fuelAmount: Int
    var metalAmount: Int
    
    override var fuelCost: Int { fuelAmount }
    override var metalCost: Int { metalAmount }
    
    init(fuelAmount: Int, metalAmount: Int, direction: Direction, tankId: UUID, precedence: Int) {
        self.fuelAmount = fuelAmount
        self.metalAmount = metalAmount
        super.init(direction: direction, tankId: tankId, precedence: precedence)
    }
    
    override func execute() -> Bool {
        if super.execute() {
            Game.shared.board.objects.append(Gift(coordinates: destinationCoordinates, fuelReward: fuelAmount, metalReward: metalAmount, containedModule: nil, uuid: UUID()))
        }
        return false
    }
    
    override var icon: String { "gift" }
}

class MoveDrone: TankAction, SingleDirectionAction {
    override var fuelCost: Int { 2 }
    
    var direction: Direction
    
    var drone: Drone {
        Game.shared.board.objects.first { (tank.modules.first { $0 is DroneModule } as! DroneModule).droneId == $0.uuid } as! Drone
    }
    
    override var icon: String { "drone" }
    
    override var isAllowed: Bool {
        if super.isAllowed {
            return tank.modules.contains(where: { $0 is DroneModule })
        }
        return false
    }
    
    override func execute() -> Bool {
        if super.execute() {
            drone.coordinates = Coordinates(x: drone.coordinates!.x + direction.changeInXValue, y: drone.coordinates!.y + direction.changeInYValue, level: drone.coordinates!.level)
            return true
        }
        return false
    }
    
    init(_ direction: Direction, tankId: UUID) {
        self.direction = direction
        super.init(tankId: tankId, precedence: 0)
    }
}
