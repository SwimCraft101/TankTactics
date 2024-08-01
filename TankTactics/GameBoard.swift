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

let scoutExample     = Appearance(fillColor: .green,  strokeColor: .black, textColor: .black, symbol: "SC")
let berserkerExample = Appearance(fillColor: .red,    strokeColor: .black, textColor: .black, symbol: "BZ")
let defenderExample  = Appearance(fillColor: .blue,   strokeColor: .black, textColor: .black, symbol: "DF")
let espionaurExample = Appearance(fillColor: .black,  strokeColor: .white, textColor: .white, symbol: "EP")
let commanderExample = Appearance(fillColor: .yellow, strokeColor: .black, textColor: .black, symbol: "CM")
let engineerExample  = Appearance(fillColor: .orange, strokeColor: .black, textColor: .black, symbol: "EN")

var board: Board = Board([
    Scout      (appearance: scoutExample,     coordinates: Coordinates(x: 2,  y: -2)),
    Berserker  (appearance: berserkerExample, coordinates: Coordinates(x: -2, y: -2)),
    Defender   (appearance: defenderExample,  coordinates: Coordinates(x: -2, y: 2 )),
    Espionaur  (appearance: espionaurExample, coordinates: Coordinates(x: 2,  y: 2 )),
    Commander  (appearance: commanderExample, coordinates: Coordinates(x: 0,  y: 0 )),
    Engineer   (appearance: engineerExample,  coordinates: Coordinates(x: 5,  y: 5 )),
    Wall       ( /*                    */     coordinates: Coordinates(x: 3,  y: 0 )),
    Wall       ( /*                    */     coordinates: Coordinates(x: 2,  y: 0 )),
    Wall       ( /*                    */     coordinates: Coordinates(x: -3, y: 0 )),
    Wall       ( /* Appearance implied */     coordinates: Coordinates(x: -2, y: 0 )),
    Wall       ( /* as a subclass of   */     coordinates: Coordinates(x: 0,  y: 3 )),
    Wall       ( /* BoardObject        */     coordinates: Coordinates(x: 0,  y: 2 )),
    Wall       ( /*                    */     coordinates: Coordinates(x: 0,  y: -3)),
    Wall       ( /*                    */     coordinates: Coordinates(x: 0,  y: -2)),
])

