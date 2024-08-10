//
//  GameBoard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/29/24.
//

class Board {
    var objects: [BoardObject]
    init(_ boardObjects: [BoardObject]) {
        objects = boardObjects
    }
}


let placeholderDemographics = PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "Apple Park", deliveryType: "Pond", deliveryNumber: 314)


var board: Board = Board([
    Wall(coordinates: Coordinates(x: 3,  y: 0 )),
    Wall(coordinates: Coordinates(x: 2,  y: 0 )),
    Wall(coordinates: Coordinates(x: -3, y: 0 )),
    Wall(coordinates: Coordinates(x: -2, y: 0 )),
    Wall(coordinates: Coordinates(x: 0,  y: 3 )),
    Wall(coordinates: Coordinates(x: 0,  y: 2 )),
    Wall(coordinates: Coordinates(x: 0,  y: -3)),
    Wall(coordinates: Coordinates(x: 0,  y: -2)),
])

