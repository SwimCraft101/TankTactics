//  Tank.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/6/24.
//
//  Defines all tank types and attributes

func power(base: Double, exponent: Int) -> Double {
    if exponent == 0 { return 1 }
    var value = base
    for _ in 1...exponent {
        value *= base
    }
    return value
}

struct PlayerDemographics {
    let firstName: String
    let lastName: String
    let deliveryBuilding: String // Should be North, Virginia, or Lingle halls
    let deliveryType: String // Should be "locker" for North Hall, "room", or a house name for Lingle.
    let deliveryNumber: String // Should be a Locker Number or Room Number
    
    func savedText() -> String {
        "PlayerDemographics(firstName: \"\(firstName)\", lastName: \"\(lastName)\", deliveryBuilding: \"\(deliveryBuilding)\", deliveryType: \"\(deliveryType)\", deliveryNumber: \"\(deliveryNumber)\")"
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
            return 10
        case .upgrade(let upgradeType):
            switch upgradeType {
            case .movementCost:
                return Int(power(base: 1, exponent: tank.movementCost) * 1.5 + 0)
            case .movementRange:
                return Int(power(base: 2, exponent: tank.movementRange) * 1 + 0)
            case .gunRange:
                return Int(power(base: 2, exponent: tank.gunRange) * 1 + 1)
            case .gunDamage:
                return Int(power(base: 1, exponent: tank.gunDamage) * 1 + 1)
            case .gunCost:
                return Int(power(base: 1, exponent: tank.gunCost) * 1.5 + 0)
            case .highDetailSightRange:
                return Int(power(base: 1, exponent: tank.highDetailSightRange) * 3 + 0)
            case .lowDetailSightRange:
                return Int(power(base: 1, exponent: tank.lowDetailSightRange) * 2 + 0)
            case .radarRange:
                return Int(power(base: 1, exponent: tank.radarRange) * 1 + 0)
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
                }
            }
        }
    }
}

class Tank: BoardObject {
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
    
    init(
        appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics
    ) {
        self.playerDemographics = playerDemographics
        self.dailyMessage = ""
        self.fuel = 10
        self.metal = 5
        
        self.movementCost = 10
        self.movementRange = 1
        
        self.gunRange = 1
        self.gunDamage = 5
        self.gunCost = 10
        
        self.highDetailSightRange = 1
        self.lowDetailSightRange = 2
        self.radarRange = 3
        super.init(appearance: appearance, coordinates: coordinates)
        self.health = 100
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
        
        dailyMesage: String
    ) {
        self.fuel = fuel
        self.metal = metal
        self.movementCost = movementCost
        self.movementRange = movementRange
        self.gunRange = gunRange
        self.gunDamage = gunDamage
        self.gunCost = gunCost
        self.highDetailSightRange = highDetailSightRange
        self.lowDetailSightRange = lowDetailSightRange
        self.radarRange = radarRange
        self.playerDemographics = playerDemographics
        self.dailyMessage = dailyMesage
        super.init(appearance: appearance, coordinates: coordinates)
        self.health = health
        self.defense = defense
    }
    
    func runAction(_ action: Action) {
        action.run()
    }
    
    func formattedDailyMessage() -> String {
        var words = dailyMessage.split(separator: " ")
        var rows: [String] = []
        for row in 0...25 {
            let rowMaxLength = Int(Double(25 - row) * 2 - 5.0)
            if words.isEmpty {
                break
            }
            rows.append("")
            while rowMaxLength > rows[row].count + (words.first?.count ?? 9999999) {
                rows[row] = "\(words.removeLast()) \(rows[row])"
            }
        }
        return rows.reversed().joined(separator: "\n")
    }
    
    override func move(_ direction: [Direction]) {
        if direction.count <= movementRange {
            for step in direction {
                coordinates.x += step.changeInXValue()
                coordinates.y += step.changeInYValue()
                if(!coordinates.inBounds()) {
                    coordinates.x -= step.changeInXValue()
                    coordinates.y -= step.changeInYValue()
                    health -= 10
                    return
                }
                for tile in board.objects {
                    if tile.coordinates.x == coordinates.x && tile.coordinates.y == coordinates.y && tile != self {
                        if tile is Gift {
                            metal += tile.metalDropped
                            fuel += tile.fuelDropped
                            tile.health = 0
                        } else {
                            coordinates.x -= step.changeInXValue()
                            coordinates.y -= step.changeInYValue()
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
        var bulletPosition: Coordinates = coordinates
        for step in direction {
            fuel -= gunCost
            bulletPosition.x += step.changeInXValue()
            bulletPosition.y += step.changeInYValue()
            for tile in board.objects {
                if tile.coordinates.x == bulletPosition.x && tile.coordinates.y == bulletPosition.y {
                    tile.health -= gunDamage * Int(power(base: 0.95, exponent: tile.defense))
                    return
                }
            }
        }
    }
    
    func placeWall(_ direction: Direction) {
        let wallCoordinates = Coordinates(x: coordinates.x + direction.changeInXValue(), y: coordinates.y + direction.changeInYValue())
        for tile in board.objects {
            if tile.coordinates.x == wallCoordinates.x && tile.coordinates.y == wallCoordinates.y {
                return
            }
        }
        board.objects.append(Wall(coordinates: wallCoordinates))
    }
    
    override func savedText() -> String {
        "Tank(appearance: \(appearance.savedText()), coordinates: \(coordinates.savedText()), playerDemographics: \(playerDemographics.savedText()), fuel: \(fuel), metal: \(metal), health: \(health), defense: \(defense), movementCost: \(movementCost), movementRange: \(movementRange), gunRange: \(gunRange), gunDamage: \(gunDamage), gunCost: \(gunCost), highDetailSightRange: \(highDetailSightRange), lowDetailSightRange: \(lowDetailSightRange), radarRange: \(radarRange), dailyMesage: \"\")"
    }
}
