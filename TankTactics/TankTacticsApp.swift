//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI
import AppKit

func getBoardState() -> String {
    var output: String = "[\n"
    for object in board.objects {
        output += object.savedText()
    }
    output += "\n]"
    return output
}

func runGameTick() {
    for object in board.objects {
        object.tick()
    }
    board.objects.append(board.objects.removeLast())
}

@main struct TankTacticsApp: App {
    @State var levelDisplayed: Int = 0
    var body: some Scene {
        WindowGroup {
            HSplitView {
                let level = levelDisplayed
                Viewport(coordinates: Coordinates(x: 0, y: 0, level: level), viewRenderSize: Coordinates(x: 0, y: 0).border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000)
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button("Print All Status") {
                                saveStatusCardsToPDF(board.objects.filter{ $0 is Tank } as! [Tank])
                                for virtualTank in board.objects.filter({
                                    if $0 is Tank {
                                        if ($0 as! Tank).virtualDelivery != nil {
                                            return true
                                        }
                                    }
                                    return false
                                }) {
                                    NSWorkspace.shared.open(URL(string: "mailto:\((virtualTank as! Tank).virtualDelivery!)?subject=Tank Tactics: \(Date.now.addingTimeInterval(86400).formatted(date: .complete, time: .omitted))&body=\((virtualTank as! Tank).dailyMessage)")!)
                                    createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualTank as! Tank))], fileName: "Virtual Status Card for \((virtualTank as! Tank).playerDemographics.firstName) \((virtualTank as! Tank).playerDemographics.lastName)")
                                }
                            }
                            Button("Force Game Tick") {
                                runGameTick()
                            }
                            Stepper("Level Displayed", value: $levelDisplayed)
                            Text(getBoardState())
                                .textSelection(.enabled)
                                .font(.system(size: 5))
                                .lineSpacing(0.5)
                                .lineLimit(100, reservesSpace: true)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
