//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI
import AppKit

@main struct TankTacticsApp: App {
    @State var levelDisplayed: Int = 0
    @State var showBorderWarning: Bool = false
    var DeadTanks: [DeadTank] = {
        var result: [DeadTank] = []
        for object in game.board.objects.filter({ $0 is DeadTank }) {
            result.append(object as! DeadTank)
        }
        return result
    }()
    var body: some Scene {
        WindowGroup {
            HSplitView {
                VStack(spacing: 0) {
                    ForEach(DeadTanks) { thisTile in
                        TileView(appearance: thisTile.appearance)
                            /*.contextMenu {
                                Button("􀎚 Print Status...") {
                                    saveDeadStatusCardsToPDF([thisTile], doAlignmentCompensation: true)
                                }
                                Menu("Apply Action") {
                                    if thisTile.essence >= 1 && thisTile.energy >= 1 {
                                        Menu("􀂒 Place Wall") {
                                            DirectionOptions(depth: thisTile.energy, vector: []) {
                                                for object in game.board.objects {
                                                    if object == thisTile {
                                                        DeadAction(.placeWall($0), tank: (object as! DeadTank)).run()
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Text("􀂒 Place Wall")
                                    }
                                    if thisTile.essence >= 3 && thisTile.energy >= 2 {
                                        Menu("􀅼 Place Gift") {
                                            DirectionOptions(depth: Int(thisTile.energy / 2), vector: []) {
                                                for object in game.board.objects {
                                                    if object == thisTile {
                                                        DeadAction(.placeGift($0), tank: (object as! DeadTank)).run()
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Text("􀅼 Place Gift")
                                    }
                                    if thisTile.energy >= 5 {
                                        Menu("􀅾 Harm Tank") {
                                            DirectionOptions(depth: thisTile.energy - 2, vector: []) {
                                                for object in game.board.objects {
                                                    if object == thisTile {
                                                        DeadAction(.harmTank($0), tank: (object as! DeadTank)).run()
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Text("􀅾 Harm Tank")
                                    }
                                    Section("􀄭 Transmute") {
                                        if thisTile.energy >= 2 {
                                            Button("􀆿 Channel Energy") {
                                                for object in game.board.objects {
                                                    if object == thisTile {
                                                        DeadAction(.channelEnergy, tank: (object as! DeadTank)).run()
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("􀆿 Channel Energy")
                                        }
                                        if thisTile.essence >= 2 {
                                            Button("􀋥 Burn Essence") {
                                                for object in game.board.objects {
                                                    if object == thisTile {
                                                        DeadAction(.burnEssence, tank: (object as! DeadTank)).run()
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("􀋥 Burn Essence")
                                        }
                                    }
                                }
                                Menu("􀋲 Attributes") {
                                    Section("   Player Demographics") {
                                        Text("Name: \(thisTile.playerDemographics.firstName) \(thisTile.playerDemographics.lastName)")
                                        Text("Delivery Location: \(thisTile.playerDemographics.deliveryType) \(thisTile.playerDemographics.deliveryNumber) in \(thisTile.playerDemographics.deliveryBuilding)")
                                    }
                                    Section("   Dead Tank Attributes") {
                                        Text("Essence: \(thisTile.essence)")
                                        Text("Energy: \(thisTile.energy)")
                                        Menu("Daily Message") {
                                            Text(thisTile.dailyMessage)
                                        }
                                    }
                                }
                                Button("􀈑 Delete") {
                                    game.board.objects.removeAll(where: {
                                        $0 == thisTile})
                                }
                            }*///TODO: Make the Context Menus work, assuming they are not replaced with a better system.
                    }
                }
                let level = levelDisplayed
                Viewport(coordinates: Coordinates(x: 0, y: 0, level: level), viewRenderSize: Coordinates(x: 0, y: 0).border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, showBorderWarning: showBorderWarning)
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button("Print Living Status") {
                                saveStatusCardsToPDF(game.board.objects.filter{ $0 is Tank } as! [Tank], doAlignmentCompensation: true, showBorderWarning: showBorderWarning)
                                for virtualTank in game.board.objects.filter({
                                    if $0 is Tank {
                                        if ($0 as! Tank).virtualDelivery != nil {
                                            return true
                                        }
                                    }
                                    return false
                                }) {
                                    NSWorkspace.shared.open(URL(string: "mailto:\((virtualTank as! Tank).virtualDelivery!)?subject=Tank Tactics: \(Date.now.addingTimeInterval(57600).formatted(date: .complete, time: .omitted))&body=\((virtualTank as! Tank).dailyMessage)")!)
                                    createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualTank as! Tank, showBorderWarning: showBorderWarning))], fileName: "Virtual Status Card for \((virtualTank as! Tank).playerDemographics.firstName) \((virtualTank as! Tank).playerDemographics.lastName)")
                                }
                            }
                            Button("Print Dead Status") {
                                saveDeadStatusCardsToPDF(game.board.objects.filter{ $0 is DeadTank } as! [DeadTank], doAlignmentCompensation: true)
                                //TODO: Make Dead Status Cards work in email
                            }
                            Stepper("Level Displayed", value: $levelDisplayed)
                            Toggle("Show Border Warning", isOn: $showBorderWarning)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}


precedencegroup ExponentiationPrecedence {
    higherThan: MultiplicationPrecedence
    associativity: right
}

infix operator ** : ExponentiationPrecedence

func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}

extension Array where Element: BoardObject & Equatable {
    func erasedToAnyBoardObject() -> [AnyBoardObject] {
        return self.map { AnyBoardObject($0) }
    }
}
