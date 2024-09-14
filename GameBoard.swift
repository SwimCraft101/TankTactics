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

var board: Board = Board([])
