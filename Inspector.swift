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
                        Game.shared.board.objects.removeAll { $0 == object }
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
                                object.coordinates?.x = newValue
                            }
                        }
                    ), format: .number)
                    TextField("Y", value: Binding<Int>(
                        get: { object.coordinates?.y ?? 0 },
                        set: { newValue in
                            if object.coordinates == nil {
                                object.coordinates = Coordinates(x: 0, y: newValue) // create if needed
                            } else {
                                object.coordinates?.y = newValue
                            }
                        }
                    ), format: .number)
                    TextField("Layer", value: Binding<Int>(
                        get: { object.coordinates?.level ?? 0 },
                        set: { newValue in
                            if object.coordinates == nil {
                                object.coordinates = Coordinates(x: 0, y: 0, level: newValue) // create if needed
                            } else {
                                object.coordinates?.level = newValue
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
                        set: { object.appearance!.fillColor = $0 }
                    ))
                    ColorPicker("Stroke", selection: Binding<Color>(
                        get: { object.appearance!.strokeColor ?? object.appearance!.fillColor },
                        set: { object.appearance!.strokeColor = $0 }
                    ))
                    ColorPicker("Symbol", selection: Binding<Color>(
                        get: { object.appearance!.strokeColor ?? object.appearance!.fillColor },
                        set: { object.appearance!.strokeColor = $0 }
                    ))
                    .disabled(object.appearance!.symbolColor != nil)
                    Toggle("Use Multicolor Symbol", isOn: Binding<Bool>(
                        get: { object.appearance!.symbolColor == nil },
                        set: { useMulticolorSymbol in
                            if useMulticolorSymbol {
                                object.appearance!.symbolColor = nil
                            } else {
                                object.appearance!.symbolColor = .black
                            }
                        }
                    ))
                }
                .disabled(!(object is Player))
                if let player = object as? Player {
                    VStack { // Tank/Player information
                        let playerBinding: Binding<Player> = Binding(get: {
                            return player
                        }, set: { newValue in
                            object = newValue
                        })
                        TextField("First Name", text: playerBinding.playerInfo.firstName)
                        TextField("Last Name", text: playerBinding.playerInfo.lastName)
                        TextField("Delivery Building", text: playerBinding.playerInfo.deliveryBuilding)
                        TextField("Delivery Type", text: playerBinding.playerInfo.deliveryType)
                        TextField("Delivery Number", text: playerBinding.playerInfo.deliveryNumber)
                        TextField("Email Address", text: Binding(
                            get: { player.playerInfo.virtualDelivery ?? "" },
                            set: { newValue in
                                if newValue == "" {
                                    player.playerInfo.virtualDelivery = nil
                                    return
                                }
                                player.playerInfo.virtualDelivery = newValue
                            }
                        ))
                        Toggle("Deliver by email", isOn: playerBinding.doVirtualDelivery)
                        EmptyView().padding(.top, 10)
                        Toggle("High Contrast", isOn: playerBinding.playerInfo.accessibilitySettings.highContrast)
                        Toggle("Colorblind", isOn: playerBinding.playerInfo.accessibilitySettings.colorblind)
                        Toggle("Large Text", isOn: playerBinding.playerInfo.accessibilitySettings.largeText)
                    }
                }
            }
        }
    }
}
