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

protocol ArbitraryFuelAndMetalAmountAction {
    var fuelAmount: Int { get }
    var metalAmount: Int { get }
}

enum TankAction: Identifiable, Codable {
    var tankId: UUID { fatalError() }
    var energyCost: Int { fatalError() }
    var metalCost: Int { fatalError() }
    
    static var icon: String { fatalError() }
    
    var isAllowed: Bool { fatalError() }
    
    func execute() { fatalError() }
    
    var id: UUID { UUID() }
    #warning("Is this safe?")
    
    case notImplementedYet, alsoNotImplemented
}
