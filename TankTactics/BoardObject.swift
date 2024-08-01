//
//  BoardObject.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 7/5/24.
//
import Foundation
import SwiftUI

struct Coordinates {
    var x: Int
    var y: Int
}

struct Appearance {
    let fillColor: Color
    let strokeColor: Color
    let textColor: Color
    let symbol: String
}

class BoardObject {
    let appearance: Appearance
    var coordinates: Coordinates
    
    func move(_direction: [Direction]) {
        for step in _direction {
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
        super.init(appearance: Appearance(fillColor: .black, strokeColor: .black, textColor: .black, symbol: ""), coordinates: coordinates)
    }
}
