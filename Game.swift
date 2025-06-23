//
//  Game.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation

let game = TankTacticsGame(board: Board(objects: []))

@Observable class TankTacticsGame {
    var board: Board
    
    
    init(board: Board) {
        self.board = board
    }
}
