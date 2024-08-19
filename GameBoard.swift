//
//  GameBoard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/29/24.
//

import SwiftUI

@Observable
class Board {
    var objects: [BoardObject]
    init(_ boardObjects: [BoardObject]) {
        objects = boardObjects
    }
}


let placeholderDemographics = PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "Apple Park", deliveryType: "Pond", deliveryNumber: 314)


var board: Board = Board([
    Wall(coordinates: Coordinates(x: 0,  y: 0 )),
    Wall(coordinates: Coordinates(x: 0,  y: 1 )),
    Wall(coordinates: Coordinates(x: 0,  y: 2 )),
    Wall(coordinates: Coordinates(x: 0,  y: 3 )),
    Wall(coordinates: Coordinates(x: 0,  y: -1)),
    Wall(coordinates: Coordinates(x: 0,  y: -2)),
    Wall(coordinates: Coordinates(x: 0,  y: -3)),
    Wall(coordinates: Coordinates(x: 1,  y: 0 )),
    Wall(coordinates: Coordinates(x: 2,  y: 0 )),
    Wall(coordinates: Coordinates(x: 3,  y: 0 )),
    Wall(coordinates: Coordinates(x: -1, y: 0 )),
    Wall(coordinates: Coordinates(x: -2, y: 0 )),
    Wall(coordinates: Coordinates(x: -3, y: 0 )),
    
    Gift(coordinates: Coordinates(x: 5 , y: 5 ), fuelReward: 0, metalReward: 0),
    Gift(coordinates: Coordinates(x: -5, y: -5), fuelReward: 0, metalReward: 0),
    Gift(coordinates: Coordinates(x: 5 , y: -5), fuelReward: 0, metalReward: 0),
    Gift(coordinates: Coordinates(x: -5, y: 5 ), fuelReward: 0, metalReward: 0),
    
    Tank(appearance: Appearance(fillColor: .red, strokeColor: .orange, symbolColor: .orange, symbol: "eraser.fill"), coordinates: Coordinates(x: 3 , y: 3 ), playerDemographics: placeholderDemographics, dailyMessage: lipsum),
    Tank(appearance: Appearance(fillColor: .blue, strokeColor: .blue, symbolColor: .blue, symbol: "pencil"), coordinates: Coordinates(x: -3, y: -3), playerDemographics: placeholderDemographics, dailyMessage: lipsum),
    Tank(appearance: Appearance(fillColor: .yellow, strokeColor: .yellow, symbolColor: .cyan, symbol: "trash.slash.circle.fill"), coordinates: Coordinates(x: 3 , y: -3), playerDemographics: placeholderDemographics, dailyMessage: lipsum),
    Tank(appearance: Appearance(fillColor: .orange, strokeColor: .gray, symbolColor: .gray, symbol: "headlight.high.beam"), coordinates: Coordinates(x: -3, y: 3 ), playerDemographics: placeholderDemographics, dailyMessage: lipsum),
])

