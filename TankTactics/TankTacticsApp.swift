//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI
import AppKit

var uiViewport = Viewport(coordinates: Coordinates(x: 0, y: 0), cellSize: 35, viewRenderSize: Coordinates(x: 0, y: 0).border * 2 + 3, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000)

func getBoardState() -> String {
    var output: String = "[\n"
    for object in board.objects {
        output += "\(object.savedText()),\n"
    }
    output += "]"
    return output
}

func runGameTick() {
    for object in board.objects {
        object.tick()
    }
    board.objects.append(board.objects.removeLast())
}

@main
struct TankTacticsApp: App {
    var body: some Scene {
        WindowGroup {
            HSplitView {
                uiViewport
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button("Print All Status") {
                                saveStatusCardsToPDF(board.objects.filter{ $0 is Tank } as! [Tank])
                            }
                            Button("Force Game Tick") {
                                runGameTick()
                            }
                            Text(getBoardState())
                                .textSelection(.enabled)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
