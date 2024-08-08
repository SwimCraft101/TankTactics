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

let scoutExample     = Appearance(fillColor: .green,  strokeColor: .black, symbolColor: .black, symbol: "lessthan.square")
let berserkerExample = Appearance(fillColor: .red,    strokeColor: .black, symbolColor: .black, symbol: "BZ")
let defenderExample  = Appearance(fillColor: .blue,   strokeColor: .black, symbolColor: .black, symbol: "DF")
let espionaurExample = Appearance(fillColor: .black,  strokeColor: .white, symbolColor: .white, symbol: "EP")
let commanderExample = Appearance(fillColor: .yellow, strokeColor: .black, symbolColor: .black, symbol: "CM")
let engineerExample  = Appearance(fillColor: .orange, strokeColor: .black, symbolColor: .black, symbol: "EN")
let placeholderDemographics = PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "Apple Park", deliveryType: "Pond", deliveryNumber: 314)


var board: Board = Board([
    Scout    (appearance: scoutExample,     coordinates: Coordinates(x: 2,  y: -2), playerDemographics: placeholderDemographics),
    Berserker(appearance: berserkerExample, coordinates: Coordinates(x: -2, y: -2), playerDemographics: placeholderDemographics),
    Defender (appearance: defenderExample,  coordinates: Coordinates(x: -2, y: 2 ), playerDemographics: placeholderDemographics),
    Espionaur(appearance: espionaurExample, coordinates: Coordinates(x: 2,  y: 2 ), playerDemographics: placeholderDemographics),
    Commander(appearance: commanderExample, coordinates: Coordinates(x: 0,  y: 0 ), playerDemographics: placeholderDemographics),
    Engineer (appearance: engineerExample,  coordinates: Coordinates(x: 5,  y: 5 ), playerDemographics: placeholderDemographics),
    Wall(coordinates: Coordinates(x: 3,  y: 0 )),
    Wall(coordinates: Coordinates(x: 2,  y: 0 )),
    Wall(coordinates: Coordinates(x: -3, y: 0 )),
    Wall(coordinates: Coordinates(x: -2, y: 0 )),
    Wall(coordinates: Coordinates(x: 0,  y: 3 )),
    Wall(coordinates: Coordinates(x: 0,  y: 2 )),
    Wall(coordinates: Coordinates(x: 0,  y: -3)),
    Wall(coordinates: Coordinates(x: 0,  y: -2)),
])

