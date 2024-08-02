//  Tank.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/6/24.
//
//  Defines all tank types and attributes

class Tank: BoardObject {
    var health: Int
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
        health: Int, movementCost: Int, movementSpeed: Int, gunRange: Int, gunDamage: Int, gunCost: Int, highDetailSightRange: Int, lowDetailSightRange: Int, radarRange: Int, appearance: Appearance, coordinates: Coordinates
    ) {
        self.health = health
        self.movementCost = movementCost
        self.movementSpeed = movementSpeed
        self.gunRange = gunRange
        self.gunDamage = gunDamage
        self.gunCost = gunCost
        self.highDetailSightRange = highDetailSightRange
        self.lowDetailSightRange = lowDetailSightRange
        self.radarRange = radarRange
        
        super.init(appearance: appearance, coordinates: coordinates)
    }
    
    override func move(_direction: [Direction]) {
        if _direction.count <= movementSpeed {
            for step in _direction {
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
    
    func fire(_direction: [Direction]) {
        var bulletPosition: Coordinates = coordinates
        for step in _direction {
            if fuel >= gunCost {
                fuel -= gunCost
                bulletPosition.x += step.changeInXValue()
                bulletPosition.y += step.changeInYValue()
            }
        }
        for tile in board.objects {
            if tile is Tank {
                if tile.coordinates.x == bulletPosition.x && tile.coordinates.y == bulletPosition.y {
                    (tile as! Tank).health -= gunDamage
                }
            }
        }
    }
}
 
class Scout: Tank {
    init(appearance: Appearance, coordinates: Coordinates) {
        super.init(
            health: 50,
            movementCost: 5,
            movementSpeed: 3,
            
            gunRange: 1,
            gunDamage: 5,
            gunCost: 10,
            
            highDetailSightRange: 3,
            lowDetailSightRange: 5,
            radarRange: 7,
            
            appearance: appearance,
            coordinates: coordinates
        )
        let normalAppearance = appearance
    }
    var isInvisible: Bool = false
    func specialAbility() {
        isInvisible = true
        appearance = Appearance(fillColor: .white, strokeColor: .white, textColor: .white, symbol: "")
    }
    
    
}

class Berserker: Tank {
    init(appearance: Appearance, coordinates: Coordinates) { // These modify the base player values
        super.init(
            health: 50,
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 5,
            gunDamage: 25,
            gunCost: 5,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates
        )
    }
    //TODO: Add Special Ability to attack more aggresively and riskily
}

class Defender: Tank {
    init(appearance: Appearance, coordinates: Coordinates) { // These modify the base player values
        super.init(
            health: 200,
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 3,
            gunDamage: 10,
            gunCost: 5,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates
        )
    }
    //TODO: Add Special Ability to defend something
}

class Espionaur: Tank {
    init(appearance: Appearance, coordinates: Coordinates) { // These modify the base player values
        super.init(
            health: 50,
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 1,
            gunDamage: 5,
            gunCost: 10,
            
            highDetailSightRange: 2,
            lowDetailSightRange: 3,
            radarRange: 5,
            
            appearance: appearance,
            coordinates: coordinates
        )
    }
    //TODO: Add Special Ability to interfere with other tanks
}

class Commander: Tank {
    init(appearance: Appearance, coordinates: Coordinates) { // These modify the base player values
        super.init(
            health: 50,
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 1,
            gunDamage: 5,
            gunCost: 10,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates
        )
    }
    //TODO: Add Special Ability to see other perspectives
}

class Engineer: Tank {
    init(appearance: Appearance, coordinates: Coordinates) {
        super.init(
            health: 50,
            movementCost: 10,
            movementSpeed: 2,
            
            gunRange: 4,
            gunDamage: 15,
            gunCost: 5,
            
            highDetailSightRange: 1,
            lowDetailSightRange: 2,
            radarRange: 3,
            
            appearance: appearance,
            coordinates: coordinates
        )
    }
    //TODO: Add special ability to place traps/turrets
}
