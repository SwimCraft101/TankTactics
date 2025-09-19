//
//  Inspector.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 9/8/25.
//

import Foundation
import SwiftUI

struct Inspector: View {
    @State var object: BoardObject
    init(_ object: BoardObject) {
        self.object = object
    }
    
    @Bindable private var game = Game.shared
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    BasicTileView(appearance: object.appearance, accessibilitySettings: AccessibilitySettings())
                    if object is Player {
                        Text("\((object as! Player).playerInfo.fullName)")
                    } else {
                        Text("\(object.type)")
                            .font(.title)
                    }
                }
                HStack {
                    Button("Delete", systemImage: "trash") {
                        game.board.objects.removeAll { $0 === object }
                    }
                }
                HStack { // General Information
                    TextField("Health", value: $object.health, format: .number)
                        .disabled(!(object is Player))
                    Spacer()
                    TextField("Defense", value: $object.defense, format: .number)
                        .disabled(!(object is Player))
                    Spacer()
                    TextField("X", value: Binding<Int>(
                        get: { object.coordinates?.x ?? 0 },
                        set: { newValue in
                            if object.coordinates == nil {
                                object.coordinates = Coordinates(x: newValue, y: 0) // create if needed
                            } else {
                                object.coordinates!.x(newValue)
                            }
                        }
                    ), format: .number)
                    TextField("Y", value: Binding<Int>(
                        get: { object.coordinates?.y ?? 0 },
                        set: { newValue in
                            if object.coordinates == nil {
                                object.coordinates = Coordinates(x: 0, y: newValue) // create if needed
                            } else {
                                object.coordinates!.y(newValue)
                            }
                        }
                    ), format: .number)
                    TextField("Layer", value: Binding<Int>(
                        get: { object.coordinates?.level ?? 0 },
                        set: { newValue in
                            if object.coordinates == nil {
                                object.coordinates = Coordinates(x: 0, y: 0, level: newValue) // create if needed
                            } else {
                                object.coordinates!.level(newValue)
                            }
                        }
                    ), format: .number)
                }
                if let gift = object as? Gift {
                    HStack {
                        TextField(
                            "Fuel",
                            value: Binding(
                                get: { gift.fuelDropped },
                                set: { gift.fuelDropped = $0 }
                            ),
                            format: .number
                        )
                        TextField(
                            "Metal",
                            value: Binding(
                                get: { gift.metalDropped },
                                set: { gift.metalDropped = $0 }
                            ),
                            format: .number
                        )
                    }
                }
                HStack { // Information about Appearances
                    ColorPicker("Fill", selection: Binding<Color>(
                        get: { object.appearance!.fillColor },
                        set: { object.appearance!.fillColor($0) }
                    ))
                    ColorPicker("Stroke", selection: Binding<Color>(
                        get: { object.appearance!.strokeColor ?? object.appearance!.fillColor },
                        set: { object.appearance!.strokeColor($0) }
                    ))
                    ColorPicker("Symbol", selection: Binding<Color>(
                        get: { object.appearance!.strokeColor ?? object.appearance!.fillColor },
                        set: { object.appearance!.strokeColor($0) }
                    ))
                    .disabled(object.appearance!.symbolColor != nil)
                    Toggle("Use Multicolor Symbol", isOn: Binding<Bool>(
                        get: { object.appearance!.symbolColor == nil },
                        set: { useMulticolorSymbol in
                            if useMulticolorSymbol {
                                object.appearance!.symbolColor(nil)
                            } else {
                                object.appearance!.symbolColor(.black)
                            }
                        }
                    ))
                }
                .disabled(!(object is Player))
                if let player = object as? Player {
                    VStack { // Tank/Player information
                        if let tank = player as? Tank {
                            Text("Modules")
                            VStack {
                                ForEach(tank.modules) { module in
                                    Text(module.type.name())
                                        .onTapGesture {
                                            tank.modules.removeAll { $0 === module }
                                            tank.modules.append(module)
                                        }
                                }
                            }
                        }
                        TextField("First Name", text: Binding(get: {
                            player.playerInfo.firstName
                        }, set: {
                            player.playerInfo.firstName($0)
                        }))
                        TextField("Last Name", text: Binding(get: {
                            player.playerInfo.lastName
                        }, set: {
                            player.playerInfo.lastName($0)
                        }))
                        TextField("Delivery Building", text: Binding(get: {
                            player.playerInfo.deliveryBuilding
                        }, set: {
                            player.playerInfo.deliveryBuilding($0)
                        }))
                        TextField("Delivery Type", text: Binding(get: {
                            player.playerInfo.deliveryType
                        }, set: {
                            player.playerInfo.deliveryType($0)
                        }))
                        TextField("Delivery Number", text: Binding(get: {
                            player.playerInfo.deliveryNumber
                        }, set: {
                            player.playerInfo.deliveryNumber($0)
                        }))
                        TextField("Email Address", text: Binding(
                            get: { player.playerInfo.virtualDelivery ?? "" },
                            set: { newValue in
                                if newValue == "" {
                                    player.playerInfo.virtualDelivery(nil)
                                    return
                                }
                                player.playerInfo.virtualDelivery(newValue)
                            }
                        ))
                        Toggle("Deliver by email", isOn: Binding(get: {
                            player.playerInfo.doVirtualDelivery
                        }, set: {
                            player.playerInfo.doVirtualDelivery($0)
                        }))
                        EmptyView().padding(.top, 10)
                        Toggle("High Contrast", isOn: Binding(
                            get: {
                                player.playerInfo.accessibilitySettings.highContrast
                            },
                            set: { newValue in
                                player.playerInfo.accessibilitySettings({
                                    var settings = player.playerInfo.accessibilitySettings
                                    settings.highContrast(newValue)
                                    return settings
                                }())
                            }
                        ))
                        Toggle("Colorblind", isOn: Binding(
                            get: {
                                player.playerInfo.accessibilitySettings.colorblind
                            },
                            set: { newValue in
                                player.playerInfo.accessibilitySettings({
                                    var settings = player.playerInfo.accessibilitySettings
                                    settings.colorblind(newValue)
                                    return settings
                                }())
                            }
                        ))
                        Toggle("Large Text", isOn: Binding(
                            get: {
                                player.playerInfo.accessibilitySettings.largeText
                            },
                            set: { newValue in
                                player.playerInfo.accessibilitySettings({
                                    var settings = player.playerInfo.accessibilitySettings
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
}
