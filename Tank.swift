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
    var uuid: UUID { get }
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
    func statusCardFront() -> AnyView {
        AnyView(StatusCardFront(tank: self))
    }
    
    func statusCardBack() -> AnyView {
        AnyView(StatusCardBack(tank: self))
    }
    
    func statusCardConduitFront() -> AnyView? {
        fatalError("Conduits need rework")
    }
    
    func statusCardConduitBack() -> AnyView? {
        fatalError("Conduits need rework")
    }
    
    func virtualStatusCard() -> AnyView {
        fatalError("Fix virtual status (:")
    }
    
    static let collisionType: CollisionType = .solid
    
    let uuid: UUID
    
    var metalDropped: Int { metal }
    
    var appearance: Appearance
    
    var coordinates: Coordinates
    
    var health: Int
    
    static var isSolid: Bool { true }
    static var isRigid: Bool { true }
    
    var playerInfo: PlayerInfo
    
    var energyProduction: Int { 100 } // The amount of energy availible for this tank to use each turn.
    var metal: Int
    
    var modules: [Module]
    
    init(uuid: UUID, appearance: Appearance, coordinates: Coordinates, health: Int, playerInfo: PlayerInfo, metal: Int, modules: [Module]) {
        self.uuid = uuid
        self.appearance = appearance
        self.coordinates = coordinates
        self.health = health
        self.playerInfo = playerInfo
        self.metal = metal
        self.modules = modules
    }
}

class DeadTank: Player {
    static let collisionType: CollisionType = .incorporeal
    
    let uuid: UUID
    
    var killedById: UUID?
    var playerInfo: PlayerInfo
    var essence: Int
    var energy: Int
    
    var killer: (any Player)? {
        Game.shared.board.objects.first(where: { $0.uuid == killedById }) as? any Player
    }
    
    init(
        appearance: Appearance,
        killedById: UUID?,
        playerInfo: PlayerInfo,
        essence: Int,
        energy: Int,
        uuid: UUID?
    ) {
        self.killedById = killedById
        self.essence = essence
        self.energy = energy
        self.playerInfo = playerInfo
        self.uuid = uuid ?? UUID()
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
