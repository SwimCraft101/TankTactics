//  Tank.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/6/24.
//
//  Defines all tank types and attributes

func power(base: Double, exponent: Int) -> Double {
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
    let deliveryNumber: Int // Should be a Locker Number or Room Number
    
}

class Tank: BoardObject {
    class Action {
        var tank: Tank
        
        enum ActionType {
            case move([Direction])
            case fire([Direction])
            case placeWall(Direction)
            case upgrade(UpgradeType)
            
            enum UpgradeType {
                case movementCost
                case movementSpeed
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
        
        func fuelCost() -> Int {
            switch type {
            case .move(let directions):
                return tank.movementCost
            case .fire(let directions):
                return tank.gunCost
            case .placeWall(let direction):
                return 0
            case .upgrade(let upgradeType):
                return 0
            }
        }
        
        func metalCost() -> Int {
            switch type {
            case .move(let directions):
                return 0
            case .fire(let directions):
                return 0
            case .placeWall(let direction):
                return 5
            case .upgrade(let upgradeType):
                switch upgradeType {
                case .movementCost:
                    return Int(power(base: 1, exponent: tank.movementCost) * 1.5 + 0)
                case .movementSpeed:
                    return Int(power(base: 2, exponent: tank.movementSpeed) * 1 + 0)
                case .gunRange:
                    return Int(power(base: 2, exponent: tank.gunRange) * 1 + 1)
                case .gunDamage:
                    return Int(power(base: 1, exponent: tank.gunDamage) * 3 + 1)
                case .gunCost:
                    return Int(power(base: 1, exponent: tank.gunCost) * 1.5 + 0)
                case .highDetailSightRange:
                    return Int(power(base: 1, exponent: tank.highDetailSightRange) * 6 + 0)
                case .lowDetailSightRange:
                    return Int(power(base: 1, exponent: tank.lowDetailSightRange) * 4 + 0)
                case .radarRange:
                    return Int(power(base: 1, exponent: tank.radarRange) * 2 + 0)
                }
            }
        }
        
        func run() {
            if tank.metal >= self.metalCost() && tank.fuel >= self.fuelCost() {
                switch type {
                case .move(let directions):
                    tank.move(directions)
                case .fire(let directions):
                    tank.fire(directions)
                case .placeWall(let direction):
                    tank.placeWall(direction)
                case .upgrade(let upgradeType):
                    switch upgradeType {
                    case .movementCost:
                        tank.metal -= Int(power(base: 1, exponent: tank.movementCost) * 1.5 + 0)
                        tank.movementCost -= 1
                    case .movementSpeed:
                        tank.metal -= Int(power(base: 2, exponent: tank.movementSpeed) * 1 + 0)
                        tank.movementSpeed += 1
                    case .gunRange:
                        tank.metal -= Int(power(base: 2, exponent: tank.gunRange) * 1 + 1)
                        tank.gunRange += 1
                    case .gunDamage:
                        tank.metal -= Int(power(base: 1, exponent: tank.gunDamage) * 3 + 1)
                        tank.gunDamage += 5
                    case .gunCost:
                        tank.metal -= Int(power(base: 1, exponent: tank.gunCost) * 1.5 + 0)
                        tank.gunCost -= 1
                    case .highDetailSightRange:
                        tank.metal -= Int(power(base: 1, exponent: tank.highDetailSightRange) * 6 + 0)
                        tank.highDetailSightRange += 1
                    case .lowDetailSightRange:
                        tank.metal -= Int(power(base: 1, exponent: tank.lowDetailSightRange) * 4 + 0)
                        tank.lowDetailSightRange += 1
                    case .radarRange:
                        tank.metal -= Int(power(base: 1, exponent: tank.radarRange) * 2 + 0)
                        tank.radarRange += 1
                    }
                }
            }
        }
    }
    
    var playerDemographics: PlayerDemographics
    var dailyMessage: String
    
    var fuel: Int = 10
    var metal: Int = 5
    
    var movementCost: Int = 10
    var movementSpeed: Int = 1
    
    var gunRange: Int = 1
    var gunDamage: Int = 5
    var gunCost: Int = 10
    
    var highDetailSightRange: Int = 1
    var lowDetailSightRange: Int = 2
    var radarRange: Int = 3
    
    init(
        appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics, dailyMessage: String
    ) {
        self.playerDemographics = playerDemographics
        self.dailyMessage = dailyMessage
        super.init(appearance: appearance, coordinates: coordinates)
        self.health = 100
    }
    
    func setDailyMessage(_ message: String) {
        dailyMessage = message
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
        if direction.count <= movementSpeed {
            for step in direction {
                fuel -= movementCost
                coordinates.x += step.changeInXValue()
                coordinates.y += step.changeInYValue()
                for tile in board.objects {
                    if tile.coordinates.x == coordinates.x && tile.coordinates.y == coordinates.y {
                        coordinates.x -= step.changeInXValue()
                        coordinates.y -= step.changeInYValue()
                        health -= 10
                        tile.health -= 10
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
        }
        for tile in board.objects {
            if tile.coordinates.x == bulletPosition.x && tile.coordinates.y == bulletPosition.y {
                tile.health -= gunDamage * Int(power(base: 0.95, exponent: tile.defence))
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
}
