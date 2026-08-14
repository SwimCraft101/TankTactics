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

protocol TankAction: Identifiable {
    var tankId: UUID { get }
    var energyCost: Int { get }
    var metalCost: Int { get }
    
    static var icon: String { get }
    
    var isAllowed: Bool { get }
    
    func execute()
}
