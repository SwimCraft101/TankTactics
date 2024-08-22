//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI

@main
struct TankTacticsApp: App {
    var body: some Scene {
        WindowGroup {
            HSplitView {
                Viewport(board: board, coordinates: Coordinates(x: 0, y: 0), cellSize: 35, viewRenderSize: 7, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000)
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button("Print All Status") {
                                saveStatusCardsToPDF(board.objects.filter{ $0 is Tank } as! [Tank])
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
