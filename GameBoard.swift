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

var board: Board = Board([
    TankPlaceholder(coordinates: Coordinates(x: 0, y: 0)),
    TankPlaceholder(coordinates: Coordinates(x: 1, y: 0)),
    TankPlaceholder(coordinates: Coordinates(x: 2, y: 0)),
    Tank(appearance: Appearance(fillColor: .red, strokeColor: .red, symbolColor: .red, symbol: ""), coordinates: Coordinates(x: 5, y: -4), playerDemographics: PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "North", deliveryType: "Locker", deliveryNumber: "53"))
])

class TankPlaceholder: BoardObject {
    init(coordinates: Coordinates) {
        super.init(appearance: Appearance(fillColor: .gray, strokeColor: .black, symbolColor: .black, symbol: "questionmark.square.dashed"), coordinates: coordinates)
    }
    override func savedText() -> String {
        "TankPlaceholder(coordinates: \(coordinates.savedText())))"
    }
}

#Preview("Board") {
    Viewport(coordinates: Coordinates(x: 0, y: 0), cellSize: 250, viewRenderSize: Coordinates(x: 0, y: 0).border * 2 + 3, highDetailSightRange: 999, lowDetailSightRange: 999, radarRange: 999)
}
