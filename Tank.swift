//  Tank.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/6/24.
//
//  Defines all tank types and attributes

func power(base: Double, exponent: Int) -> Int {
    var value = base
    for iterator in 1...exponent {
        value *= base
    }
    return Int(value)
}

struct PlayerDemographics {
    let firstName: String
    let lastName: String
    let deliveryBuilding: String // Should be North, Virginia, or Lingle halls
    let deliveryType: String // Should be "locker" for North Hall, "room", or a house name for Lingle.
    let deliveryNumber: Int // Should be a Locker Number or Room Number
    
}

class Tank: BoardObject {
    var playerDemographics: PlayerDemographics

    var fuel: Int = 0
    
    var movementCost: Int
    var movementSpeed: Int
    
    var gunRange: Int
    var gunDamage: Int
    var gunCost: Int
    
    var highDetailSightRange: Int
    var lowDetailSightRange: Int
    var radarRange: Int
    
    init(
        defence: Int, movementCost: Int, movementSpeed: Int, gunRange: Int, gunDamage: Int, gunCost: Int, highDetailSightRange: Int, lowDetailSightRange: Int, radarRange: Int, appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics
    ) {
        self.movementCost = movementCost
        self.movementSpeed = movementSpeed
        self.gunRange = gunRange
        self.gunDamage = gunDamage
        self.gunCost = gunCost
        self.highDetailSightRange = highDetailSightRange
        self.lowDetailSightRange = lowDetailSightRange
        self.radarRange = radarRange
        self.playerDemographics = playerDemographics
        
        super.init(appearance: appearance, coordinates: coordinates)
        self.health = 100
        self.defence = defence
    }
    
    override func move(_ direction: [Direction]) {
        if direction.count <= movementSpeed {
            for step in direction {
                if fuel <= movementCost {
                    fuel -= movementCost
                    coordinates.x += step.changeInXValue()
                    coordinates.y += step.changeInYValue()
                    for tile in board.objects {
                        if tile.coordinates.x == coordinates.x && tile.coordinates.y == coordinates.y {
                            coordinates.x -= step.changeInXValue()
                            coordinates.y -= step.changeInYValue()
                            health -= 10
                            if tile is Tank {
                                (tile as! Tank).health -= 10
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fire(_ direction: [Direction]) {
        var bulletPosition: Coordinates = coordinates
        for step in direction {
            if fuel >= gunCost {
                fuel -= gunCost
                bulletPosition.x += step.changeInXValue()
                bulletPosition.y += step.changeInYValue()
            }
        }
        for tile in board.objects {
            if tile.coordinates.x == bulletPosition.x && tile.coordinates.y == bulletPosition.y {
                tile.health -= gunDamage * power(base: 0.95, exponent: tile.defence)
            }
        }
    }
}

class Scout: Tank {
    init(appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics) {
        normalAppearance = appearance
        super.init(
            defence: 0,
            
            movementCost: 5,
            movementSpeed: 3,
            
            gunRange: 1,
            gunDamage: 5,
            gunCost: 10,
            
            highDetailSightRange: 3,
            lowDetailSightRange: 5,
            radarRange: 7,
            
            appearance: appearance,
            coordinates: coordinates,
            
            playerDemographics: playerDemographics
        )
        normalAppearance = appearance
    }
    var normalAppearance: Appearance
    func specialAbility() {
        appearance = Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "rectangle.filled")
    }
    override func move(_ direction: [Direction]) {
        appearance = normalAppearance
        super.move(direction)
    }
    
    
}

class Berserker: Tank {
    init(appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics) { // These modify the base player values
        super.init(
            defence: 0,
            
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 5,
            gunDamage: 25,
            gunCost: 5,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates,
            
            playerDemographics: playerDemographics
        )
    }
    //TODO: Add Special Ability to attack more aggresively and riskily
}

class Defender: Tank {
    init(appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics) { // These modify the base player values
        super.init(
            defence: 3,

            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 3,
            gunDamage: 10,
            gunCost: 5,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates,
            
            playerDemographics: playerDemographics
        )
    }
    //TODO: Add Special Ability to defend something
}

class Espionaur: Tank {
    init(appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics) { // These modify the base player values
        super.init(
            defence: 0,
            
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 1,
            gunDamage: 5,
            gunCost: 10,
            
            highDetailSightRange: 2,
            lowDetailSightRange: 3,
            radarRange: 5,
            
            appearance: appearance,
            coordinates: coordinates,
            
            playerDemographics: playerDemographics
        )
    }
    //TODO: Add Special Ability to interfere with other tanks
}

class Commander: Tank {
    init(appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics) { // These modify the base player values
        super.init(
            defence: 0,
            
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 1,
            gunDamage: 5,
            gunCost: 10,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates,
            
            playerDemographics: playerDemographics
        )
    }
    //TODO: Add Special Ability to see other perspectives
}

class Engineer: Tank {
    init(appearance: Appearance, coordinates: Coordinates, playerDemographics: PlayerDemographics) {
        super.init(
            defence: 0,
            
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 4,
            gunDamage: 15,
            gunCost: 5,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates,
            
            playerDemographics: playerDemographics
        )
    }
    //TODO: Add special ability to place traps/turrets
}

