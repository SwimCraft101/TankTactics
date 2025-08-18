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
    return inches * 288
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

struct StatusCardFront: View {
    let tank: Tank
    let showBorderWarning: Bool
    var body: some View {
        ZStack {
            TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, showBorderWarning: false) //MARK: reference real showBorderWarning value
                .frame(width: inch(4), height: inch(4), alignment: .bottomLeading)
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(5), height: inch(8), alignment: .topTrailing)
            ControlPanelView(tank: tank)
                .frame(width: inch(4), height: inch(4), alignment: .topTrailing)
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(5), height: inch(8), alignment: .bottomLeading)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(tank.playerDemographics.deliveryType)
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                            .font(.system(size: inch(0.35)))
                        Text(" \(tank.playerDemographics.deliveryNumber)")
                            .foregroundColor(.black)
                            .fontWeight(.black)
                            .font(.system(size: inch(0.35)))
                    }
                    Text(tank.playerDemographics.deliveryBuilding)
                        .foregroundColor(.black)
                        .fontWeight(.light)
                        .font(.system(size: inch(0.35)))
                        .italic()
                }
                .frame(width: inch(2.5), height: inch(1), alignment: .center)
                .frame(width: inch(3.5), height: inch(1), alignment: .leading)
                .frame(width: inch(4), height: inch(1), alignment: .trailing)
                .frame(width: inch(4), height: inch(4), alignment: .bottom)
                .rotationEffect(Angle(degrees: 90))
                .frame(width: inch(5), height: inch(8), alignment: .top)
                VStack(spacing: 0) {
                    Text(tank.playerDemographics.lastName)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.system(size: inch(0.35)))
                    Text(tank.playerDemographics.firstName)
                        .foregroundColor(.black)
                        .fontWeight(.ultraLight)
                        .font(.system(size: inch(0.35)))
                }
                .frame(width: inch(2.5), height: inch(1), alignment: .center)
                .frame(width: inch(3.5), height: inch(1), alignment: .leading)
                .frame(width: inch(4), height: inch(1), alignment: .trailing)
                .frame(width: inch(4), height: inch(4), alignment: .bottom)
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(5), height: inch(8), alignment: .bottom)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if tank.fuel >= tank.metal {
                        fuelMeter(tank.fuel)
                    } else {
                        metalMeter(tank.metal)
                    }
                }
                .frame(width: inch(5), height: inch(4), alignment: .leading)
                HStack(spacing: 0) {
                    healthMeter(tank.health)
                }
                .frame(width: inch(5), height: inch(4), alignment: .trailing)
                
            }
            Text("This text renders on the back of the Status Card.") //empty for now (:
                .font(.system(size: inch(0.15)))
                .italic()
                .frame(width: inch(3.1819805153), height: inch(2.4748737342), alignment: .center)
                .rotationEffect(Angle(degrees: -45))
            
        }
    }
}

struct StatusCardBack: View {
    let tank: Tank
    var topModule: Module? {
        let availibleModules = tank.modules
        if availibleModules.isEmpty { return nil }
        if availibleModules[0] is ConduitModule && availibleModules[1] is ConduitModule {
            return availibleModules[safe: 2]
        }
        if availibleModules[0] is ConduitModule {
            return availibleModules[safe: 1]
        }
        return availibleModules[safe: 0]
    }
    var bottomModule: Module? {
        let availibleModules = tank.modules
        if availibleModules.count < 2 { return nil }
        if availibleModules[0] is ConduitModule && availibleModules[1] is ConduitModule {
            return availibleModules[safe: 3]
        }
        if availibleModules[0] is ConduitModule {
            return availibleModules[safe: 2]
        }
        return availibleModules[safe: 1]
    }
    let showBorderWarning: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        if tank.fuel >= tank.metal {
                            fuelMeter(tank.fuel)
                            metalMeter(tank.metal)
                        } else if tank.fuel + tank.metal > 0 {
                            metalMeter(tank.metal)
                            fuelMeter(tank.fuel)
                        } else {
                            defenseMeter(tank.defense)
                        }
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .leading)
                    if topModule == nil {
                        TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, showBorderWarning: false) //MARK: reference real value of ShowBorderWarning
                            .frame(width: inch(4), height: inch(4), alignment: .topTrailing)
                    } else {
                        ModuleView(module: topModule!)
                    }
                }
                .frame(width: inch(5), height: inch(4), alignment: .top)
                HStack(spacing: 0) {
                    if bottomModule == nil {
                        ControlPanelView(tank: tank)
                            .frame(width: inch(4), height: inch(4), alignment: .topLeading)
                    } else {
                        ModuleView(module: bottomModule!)
                    }
                    HStack(spacing: 0) {
                        if tank.fuel + tank.metal > 0 {
                            MeterView(value: tank.defense, max: 20, color: .blue, label: "defense", icon: "shield.righthalf.filled")
                        }
                        MeterView(value: tank.health, max: 100, color: .red, label: "health", icon: "bolt.heart")
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .trailing)
                }
                .frame(width: inch(5), height: inch(4), alignment: .bottom)
            }
        }
    }
}

struct ControlPanelView: View {
    let tank: Tank
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    switch game.gameDay {
                    case .monday:
                        Text("") //MARK: Add Module Purchasing
                    case .tuesday:
                        Text("Moving and Firing are 50% cheaper today. Two Event Cards are availible.")
                    case .wednesday:
                        Grid(alignment: .center, horizontalSpacing: inch(0.1), verticalSpacing: 0) {
                            GridRow {
                                Image(systemName: "car.rear.road.lane.distance.\(max(1, min(tank.movementRange, 5)))")
                                    .font(.system(size: inch(0.2)))
                                Text("Movement Range")
                                    .font(.system(size: inch(0.2)))
                                    .lineLimit(1)
                                Text("\(5/*MARK: get actual price*/)􀇷")
                                    .font(.system(size: inch(0.15)))
                                Text("\(tank.movementRange)􀂒 􀄫 \(tank.movementRange + 1)􀂒")
                                    .font(.system(size: inch(0.15)))
                            }
                            
                            GridRow {
                                Image(systemName: {
                                    switch tank.movementCost {
                                    case 10, 9:
                                        return "gauge.with.dots.needle.0percent"
                                    case 8, 7:
                                        return "gauge.with.dots.needle.33percent"
                                    case 6, 5:
                                        return "gauge.with.dots.needle.50percent"
                                    case 4, 3:
                                        return "gauge.with.dots.needle.67percent"
                                    default: ///``` case 2, 1:
                                        return "gauge.with.dots.needle.100percent"
                                    }
                                }())
                                    .font(.system(size: inch(0.2)))
                                Text("Movement Efficiency")
                                    .font(.system(size: inch(0.2)))
                                    .lineLimit(1)
                                Text("\(5/*MARK: get actual price*/)􀇷")
                                    .font(.system(size: inch(0.15)))
                                Text("\(tank.movementCost)􀵞 􀄫 \(tank.movementCost - 1)􀵞")
                                    .font(.system(size: inch(0.15)))
                            }
                        }
                    case .thursday:
                        EmptyView()
                    case .friday:
                        Grid(alignment: .center, horizontalSpacing: inch(0.1), verticalSpacing: 0) {
                            GridRow {
                                Image(systemName: "car.rear.road.lane.distance.\(max(1, min(tank.movementRange, 5)))")
                                    .font(.system(size: inch(0.2)))
                                Text("Weapon Range")
                                    .font(.system(size: inch(0.2)))
                                Text("\(5/*MARK: get actual price*/)􀇷")
                                    .font(.system(size: inch(0.2)))
                                Text("\(tank.movementRange)􀂒 􀄫 \(tank.movementRange + 1)􀂒")
                                    .font(.system(size: inch(0.2)))
                            }
                            
                            GridRow {
                                Image(systemName: {
                                    switch tank.movementCost {
                                    case 10, 9:
                                        return "gauge.with.dots.needle.0percent"
                                    case 8, 7:
                                        return "gauge.with.dots.needle.33percent"
                                    case 6, 5:
                                        return "gauge.with.dots.needle.50percent"
                                    case 4, 3:
                                        return "gauge.with.dots.needle.67percent"
                                    default: ///``` case 2, 1:
                                        return "gauge.with.dots.needle.100percent"
                                    }
                                }())
                                    .font(.system(size: inch(0.2)))
                                Text("Movement Efficiency")
                                    .font(.system(size: inch(0.2)))
                                Text("\(5/*MARK: get actual price*/)􀇷")
                                    .font(.system(size: inch(0.2)))
                                Text("\(tank.movementCost)􀵞 􀄫 \(tank.movementCost - 1)􀵞")
                                    .font(.system(size: inch(0.2)))
                            }
                        }
                    }
                }
                .frame(width: inch(3.5), height: inch(2.5), alignment: .topLeading)
                Image(systemName: {
                    switch game.gameDay {
                    case .monday:
                        return "square.on.square.dashed"
                    case .tuesday:
                        return "exclamationmark.triangle"
                    case .wednesday:
                        return "tire"
                    case .thursday:
                        return "storefront"
                    case .friday:
                        return "headlight.high.beam"
                    }
                }()) // image representing the GameDay
                .resizable()
                .scaledToFit()
                .frame(width: inch(0.25), height: inch(0.25))
                .frame(width: inch(0.5), height: inch(0.5), alignment: .topLeading)
                .frame(width: inch(0.5), height: inch(2.5), alignment: .topTrailing)
            }
            .frame(width: inch(4), height: inch(2.5))
            Grid {
                GridRow {
                    Text("")
                        .font(.system(size: inch(0.2)))
                    Text("􀐚")
                        .font(.system(size: inch(0.2)))
                    Text("􀈿")
                        .font(.system(size: inch(0.2)))
                    Text("􁘿")
                        .font(.system(size: inch(0.2)))
                }
                GridRow {
                    Text("􀵞")
                        .font(.system(size: inch(0.2)))
                    Text("__")
                        .font(.system(size: inch(0.2)))
                    Text("__")
                        .font(.system(size: inch(0.2)))
                    Text("__")
                        .font(.system(size: inch(0.2)))
                }
                GridRow {
                    Text("􀇷")
                        .font(.system(size: inch(0.2)))
                    Text("__")
                        .font(.system(size: inch(0.2)))
                    Text("__")
                        .font(.system(size: inch(0.2)))
                    Text("")
                        .font(.system(size: inch(0.2)))
                }
            } //precedence, physical token, and Event Card spending
            .frame(width: inch(4), height: inch(1.5), alignment: .topLeading)
        }
        .frame(width: inch(4), height: inch(4))
        .foregroundColor(.black)
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

func fuelMeter(_ value: Int) -> MeterView {
    return MeterView(value: value, max: 50, color: .green, label: "Fuel", icon: "fuelpump")
}

func metalMeter(_ value: Int) -> MeterView {
    return MeterView(value: value, max: 50, color: .yellow, label: "Metal", icon: "square.grid.2x2")
}

func healthMeter(_ value: Int) -> MeterView {
    return MeterView(value: value, max: 100, color: .red, label: "Health", icon: "bolt.heart")
}

func defenseMeter(_ value: Int) -> MeterView {
    return MeterView(value: value, max: 10, color: .blue, label: "Defense", icon: "shield.lefthalf.filled")
}

struct DirectionOptions: View {
    let depth: Int
    var vector: [Direction]
    var action: ([Direction]) -> Void
    
    var body: some View {
        if depth > 1  {
            Menu("􀄨 North") {
                DirectionOptions(depth: depth - 1, vector: vector + [.north], action: action)
            }
            Menu("􀄩 South") {
                DirectionOptions(depth: depth - 1, vector: vector + [.south], action: action)
            }
            Menu("􀄫 East") {
                DirectionOptions(depth: depth - 1, vector: vector + [.east], action: action)
            }
            Menu("􀄪 West") {
                DirectionOptions(depth: depth - 1, vector: vector + [.west], action: action)
            }
            if vector != [] {
                Button("􀎫 Go!") {
                    action(vector)
                }
            }
        } else {
            Button("􀄨 North") {
                action(vector + [.north])
            }
            Button("􀄩 South") {
                action(vector + [.south])
            }
            Button("􀄫 East") {
                action(vector + [.east])
            }
            Button("􀄪 West") {
                action(vector + [.west])
            }
            if vector != [] {
                Button("􀎫 Go!") {
                    action(vector)
                }
            }
        }
    }
}

struct VirtualStatusCard: View { //MARK: rework to match standard Status Card
    let tank: Tank
    let showBorderWarning: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
            }
            HStack(spacing: 0) {
                ControlPanelView(tank: tank)
                    .frame(width: inch(4), height: inch(4), alignment: .top)
                MeterView(value: tank.fuel, max: 60, color: .green, label: "fuel", icon: "fuelpump")
                MeterView(value: tank.metal, max: 60, color: .yellow, label: "metal", icon: "square.grid.2x2")
                MeterView(value: tank.defense, max: 20, color: .blue, label: "defense", icon: "shield.righthalf.filled")
                MeterView(value: tank.health, max: 100, color: .red, label: "health", icon: "bolt.heart")
            }
        }
        .frame(width: inch(8.5))
    }
}

#Preview {
    let tank = Tank(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .black, symbol: "xmark.triangle.circle.square"), coordinates: Coordinates(x: 0, y: 0), playerDemographics: PlayerDemographics(firstName: "first", lastName: "last", deliveryBuilding: "building", deliveryType: "type", deliveryNumber: "num", virtualDelivery: "email", accessibilitySettings: AccessibilitySettings(), kills: 0))
    ZStack {
        HStack(spacing: 0) {
            StatusCardFront(tank: tank, showBorderWarning: false)
        }
        .background(.white)
    }
}
