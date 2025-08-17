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
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer()
                    Text(tank.playerDemographics.firstName)
                        .foregroundColor(.black)
                        .fontWeight(.ultraLight)
                        .font(.system(size: inch(0.35)))
                    Text(tank.playerDemographics.lastName)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.system(size: inch(0.35)))
                }
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(4.5), height: inch(4), alignment: .center)
                VStack(spacing: 0) {
                    Text(tank.playerDemographics.deliveryBuilding)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .fontWeight(.light)
                        .font(.system(size: inch(0.35)))
                    HStack(spacing: 0) {
                        Text(tank.playerDemographics.deliveryType)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .fontWeight(.medium)
                            .font(.system(size: inch(0.35)))
                        Text("\(tank.playerDemographics.deliveryNumber)")
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .fontWeight(.black)
                            .font(.system(size: inch(0.35)))
                    }
                    Spacer()
                }
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(4.5), height: inch(4), alignment: .center)
            }
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer(minLength: inch(1))
                    Text(/*tank.formattedDailyMessage()*/"")
                        .font(.system(size: inch(0.15)))
                        .frame(width: inch(4), height: inch(4), alignment: .bottomLeading)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .fontDesign(.monospaced)
                }
                .rotationEffect(Angle(degrees: 90))
                .frame(width: inch(5), height: inch(4), alignment: .center)
                Spacer()
            }
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("")
                        .frame(width: inch(4.5), height: inch(4), alignment: .center)
                    if tank.fuel >= tank.metal {
                        MeterView(value: tank.fuel, max: 60, color: .green, label: "fuel", icon: "fuelpump")
                    } else {
                        MeterView(value: tank.metal, max: 60, color: .yellow, label: "metal", icon: "square.grid.2x2")
                    }
                    Spacer()
                }
                HStack(spacing: 0) {
                    Spacer()
                    MeterView(value: tank.health, max: 100, color: .red, label: "health", icon: "bolt.heart")
                    Image("")
                        .frame(width: inch(4.5), height: inch(4), alignment: .center)
                }
                
            }
            Text("") //empty for now (:
                .font(.system(size: inch(0.15)))
                .italic()
                .frame(width: inch(3.1819805153), height: inch(2.4748737342), alignment: .center)
                .rotationEffect(Angle(degrees: 45))
        }
    }
}

struct StatusCardBack: View {
    let tank: Tank
    let showBorderWarning: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        if tank.fuel >= tank.metal {
                            MeterView(value: tank.fuel, max: 60, color: .green, label: "fuel", icon: "fuelpump")
                            MeterView(value: tank.metal, max: 60, color: .yellow, label: "metal", icon: "square.grid.2x2")
                        } else if tank.fuel + tank.metal > 0 {
                            MeterView(value: tank.metal, max: 60, color: .yellow, label: "metal", icon: "square.grid.2x2")
                            MeterView(value: tank.fuel, max: 60, color: .green, label: "fuel", icon: "fuelpump")
                        } else {
                            MeterView(value: tank.defense, max: 20, color: .blue, label: "defense", icon: "shield.righthalf.filled")
                        }
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .leading)
                }
                .frame(width: inch(5), height: inch(4), alignment: .top)
                HStack(spacing: 0) {
                    ControlPanelView(tank: tank)
                        .frame(width: inch(4), height: inch(4), alignment: .topLeading)
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
    }
}

struct UpgradeOption: View {
    let name: String
    let currentValue: Int
    let upgradeIncrement: Int
    let upgradeCost: Int
    let unit: String
    let icon: String
    let costUnit: String
    
    var body: some View { //MARK: redesign to be slimmer
        HStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: inch(0.2)))
                .frame(width: inch(0.4))
                .foregroundColor(.black)
            Text("\(name): \(currentValue) \(unit) 􁉂 \(currentValue + upgradeIncrement) \(unit) (Costs \(upgradeCost)\(costUnit))")
                .font(.system(size: inch(0.2)))
                .foregroundColor(.black)
            Spacer()
        }
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
                        Spacer()
                        Text("\(value)")
                            .font(.system(size: inch(0.27)))
                            .foregroundColor(.black)
                            .bold()
                        Spacer()
                        if (CGFloat(value) / CGFloat(max)) >= 0.12 {
                            if (CGFloat(value) / CGFloat(max)) >= 0.2 {
                                Image(systemName: icon)
                                    .font(.system(size: inch(0.28)))
                                    .foregroundColor(.black)
                            }
                            Text(label)
                                .font(.system(size: inch(0.14)))
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
        Color.white
        HStack {
            ControlPanelView(tank: tank)
        }
    }
}
