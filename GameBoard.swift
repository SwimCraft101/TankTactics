import Observation
import SwiftUI
@Observable class Board {
    var objects: [BoardObject]
    init(_ boardObjects: [BoardObject]) {
        objects = boardObjects
    }
}

var board: Board = Board(boardObjects)

private func w(
    _ x: Int, _ y: Int, _ level: Int) -> BoardObject {
        if level == 0 && Int.random(in: 0...29) == 0 {
            return DeluxeGift(coordinates: Coordinates(x: x, y: y, level: level))
        }
        return Wall(Coordinates(x: x, y: y, level: level))
}
private func r(
    _ x: Int, _ y: Int, _ level: Int) -> RedWall {
        return RedWall(Coordinates(x: x, y: y, level: level))
}
private func g(
    _ x: Int, _ y: Int, _ level: Int, _ fuelAmount: Int, _ metalAmount: Int) -> Gift {
        return Gift(coordinates: Coordinates(x: x, y: y, level: level), fuelReward: fuelAmount, metalReward: metalAmount)
}
private func d(
    _ x: Int, _ y: Int, _ level: Int, _ fuelAmount: Int, _ metalAmount: Int) -> DeluxeGift {
        return DeluxeGift(coordinates: Coordinates(x: x, y: y, level: level), fuelReward: fuelAmount, metalReward: metalAmount)
    }
private func a(
    _ fr: Int, _ fg: Int, _ fb: Int, _ br: Int, _ bg: Int, _ bb: Int, _ sr: Int, _ sg: Int, _ sb: Int, _ symbol: String) -> Appearance {
    let fill = Color(red: CGFloat(fr) / 256, green: CGFloat(fg) / 256, blue: CGFloat(fb) / 256)
    let border = Color(red: CGFloat(br) / 256, green: CGFloat(bg) / 256, blue: CGFloat(bb) / 256)
    let symbolColor = Color(red: CGFloat(sr) / 256, green: CGFloat(sg) / 256, blue: CGFloat(sb) / 256)
    return Appearance(fillColor: fill, strokeColor: border, symbolColor: symbolColor, symbol: symbol)
}
private func c(
    _ x: Int, _ y: Int, _ level: Int) -> Coordinates {
        return Coordinates(x: x, y: y, level: level)
}
private func p(
    _ a: String, _ b: String, _ c: String, _ d: String, _ e: String, _ f: Int) -> PlayerDemographics {
        return PlayerDemographics(firstName: a, lastName: b, deliveryBuilding: c, deliveryType: d, deliveryNumber: e, kills: f)
}
private func m(
    _ sender: String, _ message: String) -> String {
    return "You receive the following message from \(sender): “\(message)” "
}
private func d(
    _ message: String) -> String {
    return "You hear a ghostly voice, haunting you and crying: “... \(message) ...”"
}
private func f(
    _ x: Int, _ y: Int) -> FireTile {
    return FireTile(coordinates: c(x,y,0))
}

let standardDailyMessage: String = ""

var boardObjects: [BoardObject] = []
