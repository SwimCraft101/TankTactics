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
        game.board.objects.first { $0.uuid == tankId } as! Tank
    }
    
    init(tankId: UUID, precedence: Int) {
        self.tankId = tankId
        self.precedence = precedence
    }
    
    var isAllowed: Bool {
        if tank.fuel < ((game.gameDay == .tuesday) ? Int(ceil(Double(fuelCost) / 2)) : fuelCost) + precedence { //halves and rounds up the fuel value on tuesdays
            return false
        }
        if tank.metal < metalCost {
            return false
        }
        return true
    }
    
    func execute() -> Bool {
        if isAllowed {
            tank.fuel -= ((game.gameDay == .tuesday) ? Int(ceil(Double(fuelCost) / 2)) : fuelCost)
            tank.metal -= metalCost
            tank.fuel -= precedence
            return true
        }
        print("The game attempted to execute an action not allowable! Tank: \(tank)")
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
    
}

class BidForEventCard: TankAction {}

class ExtractPhysicalFuelOrMetal: TankAction {}

class WednesdayUpgrade: TankAction {}

class UpgradeMovementRange: WednesdayUpgrade {}

class UpgradeMovementCost: WednesdayUpgrade {}

class ThursdayAction: TankAction {}

class SellUpgrade: ThursdayAction {}

class SellModule: ThursdayAction {}

class FridayUpgrade: TankAction {}

class UpgradeGunRange: FridayUpgrade {}

class UpgradeGunCost: FridayUpgrade {}

class UpgradeGunDamage: FridayUpgrade {}

