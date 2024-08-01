//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI

func getAppearenceAtLocation(_ coordinates: Coordinates) -> Appearance {
    for tile in board.objects {
        if tile.coordinates.x == coordinates.x && tile.coordinates.y == coordinates.y {
            return tile.appearance
        }
    }
    return Appearance(fillColor: .white, strokeColor: .white, textColor: .white, symbol: "")
}

let cellSize: CGFloat = 52

@main
struct TankTacticsApp: App {
    var body: some Scene {
        WindowGroup {                          // Make a window
            HStack {                           // Stack up each row of the board
                ForEach(-7..<8) { x in         // Run for each row
                    VStack {                   // Connect the cells into a row
                        ForEach(-7..<8) { y in // Run for each cell
                            ZStack {           // Combine these elements into a cell
                                let thisCellAppearance = getAppearenceAtLocation(Coordinates(x: x, y: -y))
                                Rectangle()
                                    .foregroundColor(thisCellAppearance.fillColor)
                                    .frame(width: cellSize, height: cellSize)
                                    .border(thisCellAppearance.strokeColor, width: cellSize / 10)
                                    .cornerRadius(cellSize / 20)
                                Text(thisCellAppearance.symbol)
                                    .bold()
                                    .font(.system(size: cellSize / 2))
                                    .foregroundColor(thisCellAppearance.textColor)
                            }
                            .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }
}
