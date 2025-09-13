//
//  Action.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/27/25.
//

import Foundation

class TankAction {
    let tankId: UUID // The UUID of the Tank performing the Action
    let precedence: Int // The amount of Fuel spent on Precedence for the action
    var fuelCost: Int { 0 } /// __ _IMPORTANT:_ THE TANK FUEL COST DOES NOT INCLUDE THE VALUE OF PRECEDENCE, NOR THE VALUE SAVED ON TUESDAYS.__
    var metalCost: Int { 0 }
    
    unowned fileprivate var tank: Tank { // Makes a reference to the actual value of the Tank instead of a copy.
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
        print("The TankTacticsGame.shared.data attempted to execute an action not allowable! Tank: \(tank)")
        return false
    }
}

class Move: TankAction {
    override var fuelCost: Int { tank.movementCost }
    let vector: [Direction]
    
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
            tank.move(vector)
            return true
        }
        return false
    }
    
    init(_ vector: [Direction], tankID: UUID, precedence: Int) {
        self.vector = vector
        super.init(tankId: tankID, precedence: precedence)
    }
}

class Fire: TankAction {
    override var fuelCost: Int { tank.gunCost }
    let vector: [Direction]
    
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
    
    init(_ vector: [Direction], tankID: UUID, precedence: Int) {
        self.vector = vector
        super.init(tankId: tankID, precedence: precedence)
    }
}

class PurchaseModule: TankAction {
    override var metalCost: Int { Game.shared.moduleOfferPrice! }
    
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

class WednesdayUpgrade: TankAction {
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
    
    override func execute() -> Bool {
        if super.execute() {
            tank.movementCost -= 1
            return true
        }
        return false
    }
}

class ThursdayAction: TankAction {}//MARK: Implement this

class SellUpgrade: ThursdayAction {}//MARK: Implement this

class SellModule: ThursdayAction {}//MARK: Implement this

class FridayUpgrade: TankAction {
    override var isAllowed: Bool {
        if Game.shared.gameDay != .friday && !(tank.modules.contains(where: { $0 is FactoryModule })) { return false }
        if super.isAllowed {
            return true
        }
        return false
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
    
    override func execute() -> Bool {
        if super.execute() {
            tank.gunDamage += 5
            return true
        }
        return false
    }
}

