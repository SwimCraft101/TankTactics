//
//  Inspector.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 9/8/25.
//

import Foundation
import SwiftUI

struct Inspector: View {
    @Binding var object: any BoardObject
    
    @Bindable private var game = Game.shared
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    BasicTileView(appearance: object.appearance, accessibilitySettings: AccessibilitySettings())
                        .frame(width: 50, height: 50)
                    if let tank = object as? Tank {
                        Text("\(tank.playerInfo.fullName)")
                            .font(.title)
                    } else if object is Wall {
                        Text("Wall")
                            .font(.title)
                    } else if object is OreDeposit {
                        Text("Wall")
                            .font(.title)
                    } else {
                        fatalError("An unrecognized boardObject was selected by the Inspector")
                    }
                }
                HStack {
                    Button("Delete", systemImage: "trash") {
                        game.board.tanks.removeAll { $0 === object as? Tank }
                        game.board.walls.removeAll { $0 === object as? Tank }
                        game.board.oreDeposits.removeAll { $0 === object as? Tank }
                    }
                }
                HStack { // General Information
                    Text("Health")
                    TextField("Health", value: $object.health, format: .number)
                        .disabled(!(object is Player))
                }
                HStack {
                    Text("Coordinates")
                    Grid {
                        GridRow {
                            Text("")
                            Button("􀄨") {
                                object.coordinates.moveBy(.north)
                            }
                            Text("")
                        }
                        GridRow {
                            Button("􀄪") {
                                object.coordinates.moveBy(.west)
                            }
                            Text("")
                            Button("􀄫") {
                                object.coordinates.moveBy(.east)
                            }
                        }
                        GridRow {
                            Text("")
                            Button("􀄩") {
                                object.coordinates.moveBy(.south)
                            }
                            Text("")
                        }
                    }
                    TextField("X", value: Binding<Int>(
                        get: { object.coordinates.x },
                        set: { newValue in
                            object.coordinates.x(newValue)
                        }
                    ), format: .number)
                    TextField("Y", value: Binding<Int>(
                        get: { object.coordinates.y },
                        set: { newValue in
                            object.coordinates.y(newValue)
                        }
                    ), format: .number)
                    TextField("Layer", value: Binding<Int>(
                        get: { object.coordinates.level },
                        set: { newValue in
                            object.coordinates.level(newValue)
                        }
                    ), format: .number)
                    Spacer()
                }
                if let tank = object as? Tank {
                    HStack {
                        Text("Metal")
                        TextField(
                            "Metal",
                            value: Binding(
                                get: { tank.metal },
                                set: { tank.metal = $0 }
                            ),
                            format: .number
                        )
                        Spacer()
                    }
                }
                HStack { // Information about Appearances
                    ColorPicker("Fill", selection: Binding<Color>(
                        get: { object.appearance.fillColor },
                        set: {
                            if let tank = object as? Tank {
                                tank.appearance.fillColor($0)
                            }
                        }
                    ))
                    ColorPicker("Stroke", selection: Binding<Color>(
                        get: { object.appearance.strokeColor ?? object.appearance.fillColor },
                        set: {
                            if let tank = object as? Tank {
                                tank.appearance.strokeColor($0)
                            }
                        }
                    ))
                    if object.appearance.symbolColor != nil {
                        ColorPicker("Symbol", selection: Binding<Color>(
                            get: { object.appearance.symbolColor ?? object.appearance.strokeColor ?? object.appearance.fillColor },
                            set: {
                                if let tank = object as? Tank {
                                    tank.appearance.symbolColor($0)
                                }
                            }
                        ))
                    }
                    TextField("Symbol", text: Binding<String>(
                        get: { object.appearance.symbol },
                        set: {
                            if let tank = object as? Tank {
                                tank.appearance.symbol($0)
                            }
                        }
                    ))
                    Toggle("Use Multicolor Symbol", isOn: Binding<Bool>(
                        get: { object.appearance.symbolColor == nil },
                        set: { useMulticolorSymbol in
                            if let tank = object as? Tank {
                                if useMulticolorSymbol {
                                    tank.appearance.symbolColor(nil)
                                } else {
                                    tank.appearance.symbolColor(tank.appearance.strokeColor ?? tank.appearance.fillColor)
                                }
                            }
                        }
                    ))
                }
                .disabled(!(object is Player))
                if let tank = object as? Tank {
                    Text("Modules")
                    VStack {
                        ForEach(tank.modules) { module in
                            Text(String(describing: module))
                        }
                    }
                    HStack {
                        Text("Name")
                        TextField("First Name", text: Binding(get: {
                            tank.playerInfo.firstName
                        }, set: {
                            tank.playerInfo.firstName($0)
                        }))
                        TextField("Last Name", text: Binding(get: {
                            tank.playerInfo.lastName
                        }, set: {
                            tank.playerInfo.lastName($0)
                        }))
                    }
                    HStack {
                        Text("Delivery Location")
                        TextField("Delivery Building", text: Binding(get: {
                            tank.playerInfo.deliveryBuilding
                        }, set: {
                            tank.playerInfo.deliveryBuilding($0)
                        }))
                        TextField("Delivery Type", text: Binding(get: {
                            tank.playerInfo.deliveryType
                        }, set: {
                            tank.playerInfo.deliveryType($0)
                        }))
                        TextField("Delivery Number", text: Binding(get: {
                            tank.playerInfo.deliveryNumber
                        }, set: {
                            tank.playerInfo.deliveryNumber($0)
                        }))
                    }
                    HStack {
                        Text("Email")
                        TextField("Email Address", text: Binding(
                            get: { tank.playerInfo.virtualDelivery ?? "" },
                            set: { newValue in
                                if newValue == "" {
                                    tank.playerInfo.virtualDelivery(nil)
                                    return
                                }
                                tank.playerInfo.virtualDelivery(newValue)
                            }
                        ))
                        Toggle("Deliver by email", isOn: Binding(get: {
                            tank.playerInfo.doVirtualDelivery
                        }, set: {
                            tank.playerInfo.doVirtualDelivery($0)
                        }))
                    }
                    EmptyView().padding(.top, 10)
                    Toggle("High Contrast", isOn: Binding(
                        get: {
                            tank.playerInfo.accessibilitySettings.highContrast
                        },
                        set: { newValue in
                            tank.playerInfo.accessibilitySettings({
                                var settings = tank.playerInfo.accessibilitySettings
                                settings.highContrast(newValue)
                                return settings
                            }())
                        }
                    ))
                    Toggle("Colorblind", isOn: Binding(
                        get: {
                            tank.playerInfo.accessibilitySettings.colorblind
                        },
                        set: { newValue in
                            tank.playerInfo.accessibilitySettings({
                                var settings = tank.playerInfo.accessibilitySettings
                                settings.colorblind(newValue)
                                return settings
                            }())
                        }
                    ))
                    Toggle("Large Text", isOn: Binding(
                        get: {
                            tank.playerInfo.accessibilitySettings.largeText
                        },
                        set: { newValue in
                            tank.playerInfo.accessibilitySettings({
                                var settings = tank.playerInfo.accessibilitySettings
                                settings.largeText(newValue)
                                return settings
                            }())
                        }
                    ))
                }
            }
        }
    }
}
