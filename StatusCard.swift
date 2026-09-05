//
//  StatusCard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/9/24.
//

import SwiftUI
import AppKit
import Foundation

func inch(_ inches: CGFloat) -> CGFloat {
    return inches * 576
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct TooManyModules: View {
    let tank: Tank
    var body: some View {
        let numberOfConduits = tank.modules.filter { $0 == .conduit }.count
        let numberOfStorages = tank.modules.filter { $0 == .storage }.count
        
        VStack {
            Text("You have too many Modules!")
                .font(.system(size: inch(0.325)))
            Text("Select how to deal with them.")
                .font(.system(size: inch(0.25)))
                .italic()
            Spacer()
            Grid(horizontalSpacing: inch(0.1), verticalSpacing: 0) {
                GridRow {
                    Text("Module")
                        .font(.system(size: inch(0.15)))
                        .italic()
                    Text("Equip")
                        .font(.system(size: inch(0.15)))
                        .italic()
                    if numberOfStorages > 0 {
                        Text("Store")
                            .font(.system(size: inch(0.15)))
                            .italic()
                    }
                    Text("Remove")
                        .font(.system(size: inch(0.15)))
                        .italic()
                }
                ForEach(tank.modules.filter{ $0 != .conduit }, id: \.self) { module in
                    GridRow {
                        Text(module.name)
                            .font(.system(size: inch(0.25)))
                        Image(systemName: "square")
                            .resizable()
                            .frame(width: inch(0.2), height: inch(0.2))
                        if numberOfStorages > 0 {
                            Image(systemName: "square")
                                .resizable()
                                .frame(width: inch(0.2), height: inch(0.2))
                        }
                        Image(systemName: "square")
                            .resizable()
                            .frame(width: inch(0.2), height: inch(0.2))
                    }
                }
            }
            Spacer()
            #warning("revamp Too Many Modules because of more module types")
            Text("You may equip up to \(min(2 + numberOfConduits, 4)) Modules\(numberOfConduits > 0 ? " because of your \(numberOfConduits) Conduit \(numberOfConduits == 1 ? "Module" : "Modules")" : "")\(numberOfStorages > 0 ? ", and store one module for each Storage module you equip" : "").")
                .font(.system(size: inch(0.15)))
                .italic()
        }
        .frame(width: inch(4), height: inch(4), alignment: .top)
    }
}

struct PanelToCutOff: View {
    var body: some View {
        RightTriangle()
            .stroke(.black, lineWidth: inch(0.005))
            .fill(Color.red.opacity(0.05))
            .rotationEffect(Angle(degrees: -90))
    }
}

struct StatusCardFront: View {
    let tank: Tank
    #warning("Rework Status Cards with new Modules")
    var body: some View {
        ZStack {/*
            if tank.hasTooManyModules || topModule != nil {
                TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, accessibilitySettings: tank.playerInfo.accessibilitySettings, selectedObject: selectedObjectBindingDefault)
                    .frame(width: inch(4), height: inch(4), alignment: .bottomLeading)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: inch(5), height: inch(8), alignment: .topTrailing)
            } else {
                PanelToCutOff()
                    .frame(width: inch(4), height: inch(4), alignment: .bottomLeading)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: inch(5), height: inch(8), alignment: .topTrailing)
            }
            if !tank.hasTooManyModules && bottomModule != nil {
                ControlPanelView(tank: tank)
                    .frame(width: inch(4), height: inch(4), alignment: .topTrailing)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: inch(5), height: inch(8), alignment: .bottomLeading)
            } else {
                PanelToCutOff()
                    .frame(width: inch(4), height: inch(4), alignment: .topTrailing)
                    .rotationEffect(Angle(degrees: 90))
                    .frame(width: inch(5), height: inch(8), alignment: .bottomLeading)
            }*/
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(tank.playerInfo.deliveryType)
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                        .font(.system(size: inch(0.35)))
                    Text(" \(tank.playerInfo.deliveryNumber)")
                        .foregroundColor(.black)
                        .fontWeight(.black)
                        .font(.system(size: inch(0.35)))
                }
                Text(tank.playerInfo.deliveryBuilding)
                    .foregroundColor(.black)
                    .fontWeight(.light)
                    .font(.system(size: inch(0.35)))
                    .italic()
            }
            .frame(width: inch(2.5), height: inch(1), alignment: .center)
            .frame(width: inch(3.5), height: inch(1), alignment: .trailing)
            .frame(width: inch(4), height: inch(1), alignment: .leading)
            .frame(width: inch(4), height: inch(4), alignment: .top)
            .rotationEffect(Angle(degrees: 90))
            .frame(width: inch(5), height: inch(8), alignment: .bottom)
            
            VStack(spacing: 0) {
                Text(tank.playerInfo.firstName)
                    .foregroundColor(.black)
                    .fontWeight(.ultraLight)
                    .font(.system(size: inch(0.35)))
                Text(tank.playerInfo.lastName)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .font(.system(size: inch(0.35)))
            }
            .frame(width: inch(2.5), height: inch(1), alignment: .center)
            .frame(width: inch(3.5), height: inch(1), alignment: .leading)
            .frame(width: inch(4), height: inch(1), alignment: .trailing)
            .frame(width: inch(4), height: inch(4), alignment: .bottom)
            .rotationEffect(Angle(degrees: 90))
            .frame(width: inch(5), height: inch(8), alignment: .top)
            
            VStack(spacing: 0) {
                /*HStack(spacing: 0) {
                    if tank.fuel >= tank.metal {
                        fuelMeter(tank)
                    } else {
                        metalMeter(tank)
                    }
                }
                .frame(width: inch(5), height: inch(4), alignment: .leading)
                HStack(spacing: 0) {
                    healthMeter(tank)
                }
                .frame(width: inch(5), height: inch(4), alignment: .trailing)
                */
            }
            Text("""
                """) //renders on back of card
                .font(.system(size: inch(0.15)))
                .italic()
                .multilineTextAlignment(.center)
                .frame(width: inch(3.4), height: inch(2.5), alignment: .center)
                .frame(width: inch(3.535534), height: inch(2.715679), alignment: .center)
                .rotationEffect(Angle(degrees: -45))
            
        }
    }
}

struct StatusCardBack: View {
    let tank: Tank
    #warning("Rework Status Cards with new Modules")
    var body: some View {
        /*
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if tank.hasTooManyModules {
                        TooManyModules(tank: tank)
                    } else {
                        if topModule == nil {
                            ZStack {
                                TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, accessibilitySettings: tank.playerInfo.accessibilitySettings, selectedObject: selectedObjectBindingDefault)
                                PanelToCutOff()
                                    .rotationEffect(Angle(degrees: 180))
                            }
                                .frame(width: inch(4), height: inch(4), alignment: .topLeading)
                        } else {
                            ModuleView(module: topModule!)
                        }
                    }
                    HStack(spacing: 0) {
                        if tank.fuel >= tank.metal {
                            metalMeter(tank)
                            fuelMeter(tank)
                        } else if tank.fuel + tank.metal > 0 {
                            fuelMeter(tank)
                            metalMeter(tank)
                        } else {
                            defenseMeter(tank)
                        }
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .trailing)
                }
                .frame(width: inch(5), height: inch(4), alignment: .top)
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        healthMeter(tank)
                        if tank.fuel + tank.metal > 0 {
                            defenseMeter(tank)
                        }
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .leading)
                    if tank.hasTooManyModules || bottomModule == nil {
                        ZStack {
                            ControlPanelView(tank: tank)
                                .frame(width: inch(4), height: inch(4), alignment: .topTrailing)
                            PanelToCutOff()
                        }
                    } else {
                        ModuleView(module: bottomModule!)
                    }
                }
                .frame(width: inch(5), height: inch(4), alignment: .bottom)
            }
        }*/
    }
}

struct MeterView: View {
    let value: Int
    let max: Int
    let color: Color
    let label: String
    let icon: String
    var body: some View {
        if value > 0 {
            ZStack {
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(inch(0.1))
                    .frame(width: inch(0.5), height: inch((CGFloat(min(value, max)) / CGFloat(max) * 4)), alignment: .bottom)
                VStack(spacing: 0) {
                    if value > 0 {
                        
                        Text("\(value)")
                            .font(.system(size: inch(0.27)))
                            .foregroundColor(.black)
                            .bold()
                        Spacer()
                        if (CGFloat(value) / CGFloat(max)) >= 0.22 {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: inch(0.4), height: inch(0.4))
                            .frame(width: inch(0.5), height: inch(0.5))
                            .foregroundColor(.black)
                        }
                    }
                }
                .frame(width: inch(0.5), height: inch((CGFloat(min(value, max)) / CGFloat(max) * 4)), alignment: .bottom)
            }
            .frame(width: inch(0.5), height: inch(4), alignment: .bottom)
        } else {
            Rectangle()
                .frame(width: inch(0.5), height: inch(4), alignment: .bottom)
                .foregroundColor(.white)
        }
    }
}

func metalMeter(_ tank: Tank) -> MeterView {
    return MeterView(value: tank.metal, max: 50, color: .yellow.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Metal", icon: "square.grid.2x2")
}

func healthMeter(_ tank: Tank) -> MeterView {
    return MeterView(value: tank.health, max: 100, color: .red.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Health", icon: "bolt.heart")
}

struct DirectionOptions: View {
    let depth: Int
    var vector: [Direction]
    var action: ([Direction]) -> Void
    var rotation: Direction
    
    var body: some View {
        if depth > 1 {
            ForEach(Direction.all, id: \.self) { direction in
                Menu("\(direction.fromPerspectiveOf(rotation).arrowAndName) (\(direction.name))") {
                    DirectionOptions(depth: depth - 1, vector: vector + [direction], action: action, rotation: rotation)
                }
            }
            if vector != [] {
                Button("􀎫 Go!") {
                    action(vector)
                }
            }
        } else {
            ForEach(Direction.all, id: \.self) { direction in
                Button("\(direction.fromPerspectiveOf(rotation).arrowAndName) (\(direction.name))") {
                    action(vector + [direction])
                }
            }
            if vector != [] {
                Button("􀎫 Go!") {
                    action(vector)
                }
            }
        }
    }
}

struct RotatedDirectionOptions: View {
    let depth: Int
    var vector: [Direction]
    var action: ([Direction], Direction) -> Void
    var rotation: Direction
    
    struct RotationOptions: View {
        let label: String
        let action: ([Direction], Direction) -> Void
        let vector: [Direction]
        let rotation: Direction
        
        var body: some View {
            Menu(label) {
                Text("Choose a facing direction.")
                ForEach(Direction.all, id: \.self) { direction in
                    Button("\(direction.fromPerspectiveOf(rotation).arrowAndName)wards (Facing \(direction.name))") {
                        action(vector, direction)
                    }
                }
            }
        }
    }
    
    var body: some View {
        if depth > 1 {
            ForEach(Direction.all, id: \.self) { direction in
                Menu("\(direction.fromPerspectiveOf(rotation).arrowAndName) (\(direction.name))") {
                    RotatedDirectionOptions(depth: depth - 1, vector: vector + [direction], action: action, rotation: rotation)
                }
            }
            RotationOptions(label: "􀎫 Go!", action: action, vector: vector, rotation: rotation)
        } else {
            ForEach(Direction.all, id: \.self) { direction in
                RotationOptions(label: "\(direction.fromPerspectiveOf(rotation).arrowAndName) (\(direction.name))", action: action, vector: vector + [direction], rotation: rotation)
            }
            RotationOptions(label: "􀎫 Go!", action: action, vector: vector, rotation: rotation)
        }
    }
}

struct VirtualStatusCard: View {
    let tank: Tank
    @ObservedObject var game: Game
    
    private var messagesReceived: [Message] {
        return game.messages.filter { $0.recipient == tank.uuid }
    }
    
    var body: some View {
        fatalError("Please implement Virtual Status Cards")
    }
}
