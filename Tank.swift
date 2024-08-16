//  Tank.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/6/24.
//
//  Defines all tank types and attributes

func power(base: Double, exponent: Int) -> Int {
    var value = base
    for _ in 1...exponent {
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
                if fuel <= movementCost {
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
    
    func placeWall(direction: Direction) {
        let wallCoordinates = Coordinates(x: coordinates.x + direction.changeInXValue(), y: coordinates.y + direction.changeInYValue())
        for tile in board.objects {
            if tile.coordinates.x == wallCoordinates.x && tile.coordinates.y == wallCoordinates.y {
                return
            }
        }
        board.objects.append(Wall(coordinates: wallCoordinates))
    }
}
