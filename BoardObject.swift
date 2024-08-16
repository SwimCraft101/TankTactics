//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI

struct Coordinates: Equatable {
    var x: Int
    var y: Int
    
    func distanceTo(_ other: Coordinates) -> Int {
        var deltax = abs(other.x - x)
        var deltay = abs(other.y - y)
        deltax *= deltax
        deltay *= deltay
        return Int(sqrt(Double(deltax + deltay)) + 0.5)
    }
}

struct Appearance: Equatable {
    let fillColor: Color
    let strokeColor: Color
    let symbolColor: Color
    let symbol: String
}

class BoardObject: Equatable {
    static func == (lhs: BoardObject, rhs: BoardObject) -> Bool {
        return lhs.coordinates == rhs.coordinates &&
        lhs.appearance == rhs.appearance
    }
    
    var fuelDropped: Int = 0
    var metalDropped: Int = 0
    
    var appearance: Appearance
    var coordinates: Coordinates
    var health: Int = 1
    var defence: Int = 0
    
    func tick() {
        if health <= 0 {
            board.objects.removeAll(where: {
                $0 == self
            })
            board.objects.append(Gift(coordinates: self.coordinates, fuelReward: fuelDropped, metalReward: metalDropped))
        }
    }
    
    func move(_ direction: [Direction]) {
        for step in direction {
            self.coordinates.x += step.changeInXValue()
            self.coordinates.y += step.changeInYValue()
        }
    }
    
    init(appearance: Appearance, coordinates: Coordinates) {
        self.appearance = appearance
        self.coordinates = coordinates
    }
}

class Wall: BoardObject {
    init(coordinates: Coordinates) {
        super.init(appearance: Appearance(fillColor: .black, strokeColor: .black, symbolColor: .black, symbol: "rectangle.fill"), coordinates: coordinates)
    }
}

class Gift: BoardObject {
    init(coordinates: Coordinates, fuelReward: Int, metalReward: Int) {
        super.init(appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "gift"), coordinates: coordinates)
        fuelDropped = fuelReward
        metalDropped = metalReward
    }
}
