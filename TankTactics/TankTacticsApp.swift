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
    return Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "square.fill")
}

let cellSize: CGFloat = 52

@main
struct TankTacticsApp: App {
    var body: some Scene {
        WindowGroup {                                      // Make a window
            HStack {
                HStack {                                       // Stack up each row of the board
                    ForEach(-7...7, id: \.self) { x in         // Run for each row
                        VStack {                               // Connect the cells into a row
                            ForEach(-7...7, id: \.self) { y in // Run for each cell
                                ZStack {                       // Combine these elements into a cell
                                    Rectangle()
                                        .foregroundColor(getAppearenceAtLocation(Coordinates(x: x, y: -y)).fillColor)
                                        .frame(width: cellSize, height: cellSize)
                                        .border(getAppearenceAtLocation(Coordinates(x: x, y: -y)).strokeColor, width: cellSize / 10)
                                        .cornerRadius(cellSize / 20)
                                    Image(systemName: getAppearenceAtLocation(Coordinates(x: x, y: -y)).symbol)
                                        .foregroundColor(getAppearenceAtLocation(Coordinates(x: x, y: -y)).symbolColor)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                                }
                                .frame(width: cellSize, height: cellSize)
                                .padding(.all, -10)
                            }
                        }
                    }
                }
                Spacer()
                Button("Print Example Status Card") {
                    printStatusCard(Scout(appearance: scoutExample, coordinates: Coordinates(x: 4, y: -4), playerDemographics: placeholderDemographics))
                }
            }
        }
    }
}
