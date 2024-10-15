
import SwiftUI

@Observable class Board {
    var objects: [BoardObject]
    init(_ boardObjects: [BoardObject]) {
        objects = boardObjects
    }
}

var board: Board = Board(boardObjects)

class TankPlaceholder: BoardObject {
    init(coordinates: Coordinates) {
        super.init(appearance: Appearance(fillColor: .gray, strokeColor: .black, symbolColor: .black, symbol: "questionmark.square.dashed"), coordinates: coordinates)
    }
    override func savedText() -> String {
        "TankPlaceholder(coordinates: \(coordinates.savedText()))"
    }
}

#Preview("Board") {
    Viewport(coordinates: Coordinates(x: 0, y: 0), cellSize: 250, viewRenderSize: Coordinates(x: 0, y: 0).border * 2 + 3, highDetailSightRange: 999, lowDetailSightRange: 999, radarRange: 999)
}

var boardObjects: [BoardObject] = [
    Tank(appearance: Appearance(fillColor: Color(red: 0.03921568766236305, green: 0.5176470279693604, blue: 1.0), strokeColor: Color(red: 0.0, green: 0.0, blue: 0.0), symbolColor: Color(red: 0.0, green: 0.0, blue: 0.0), symbol: "person.crop.circle"), coordinates: Coordinates(x: 5, y: -4), playerDemographics: PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "North", deliveryType: "locker", deliveryNumber: "-504"), fuel: 100, metal: 50, health: 100, defense: 0, movementCost: 10, movementRange: 3, gunRange: 3, gunDamage: 5, gunCost: 10, highDetailSightRange: 1, lowDetailSightRange: 2, radarRange: 3, dailyMesage: ""),
    ]
