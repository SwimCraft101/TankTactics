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

struct TooManyModules: View {
    let tank: Tank
    var body: some View {
        let numberOfConduits = tank.modules.filter { $0 is ConduitModule }.count
        let numberOfStorages = tank.modules.filter { $0 is StorageModule }.count
        
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
                ForEach(tank.modules.filter{!($0 is ConduitModule)}, id: \.self) { module in
                    GridRow {
                        Text(module.type.name())
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
            Text("You may equip up to \(min(2 + numberOfConduits, 4)) Modules\(numberOfConduits > 0 ? " because of your \(numberOfConduits) Conduit \(numberOfConduits == 1 ? "Module" : "Modules")" : "")\(numberOfStorages > 0 ? ", and store one module for every Storage module you equip" : "").")
                .font(.system(size: inch(0.15)))
                .italic()
        }
        .frame(width: inch(4), height: inch(4), alignment: .top)
    }
}

struct RightTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Draw a line to the bottom-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Draw a line to the top-left corner (forming the right angle)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        // Close the path back to the starting point
        path.closeSubpath()

        return path
    }
}

struct PanelToCutOff: View {
    var body: some View {
        RightTriangle()
            .fill(Color.red.opacity(0.05))
            .rotationEffect(Angle(degrees: -90))
    }
}

struct StatusCardFront: View {
    let tank: Tank
    let showBorderWarning: Bool
    var topModule: Module? {
        return tank.displayedModules[safe: 0]
    }
    var bottomModule: Module? {
        return tank.displayedModules[safe: 1]
    }
    var body: some View {
        ZStack {
            if tank.hasTooManyModules || topModule != nil {
                TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, showBorderWarning: false, accessibilitySettings: tank.playerInfo.accessibilitySettings) //MARK: reference real showBorderWarning value
                    
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
            }
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
                Text(tank.playerInfo.lastName)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .font(.system(size: inch(0.35)))
                Text(tank.playerInfo.firstName)
                    .foregroundColor(.black)
                    .fontWeight(.ultraLight)
                    .font(.system(size: inch(0.35)))
            }
            .frame(width: inch(2.5), height: inch(1), alignment: .center)
            .frame(width: inch(3.5), height: inch(1), alignment: .leading)
            .frame(width: inch(4), height: inch(1), alignment: .trailing)
            .frame(width: inch(4), height: inch(4), alignment: .bottom)
            .rotationEffect(Angle(degrees: 90))
            .frame(width: inch(5), height: inch(8), alignment: .top)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
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
                
            }
            Text("") //renders on back of card
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
        return tank.displayedModules[safe: 0]
    }
    var bottomModule: Module? {
        return tank.displayedModules[safe: 1]
    }
    let showBorderWarning: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    if tank.hasTooManyModules {
                        TooManyModules(tank: tank)
                    } else {
                        if topModule == nil {
                            ZStack {
                                TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, showBorderWarning: false, accessibilitySettings: tank.playerInfo.accessibilitySettings) //MARK: reference real value of ShowBorderWarning
                                    
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
        }
    }
}

struct ControlPanelView: View {
    let tank: Tank
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    switch Game.shared.gameDay {
                    case .monday:
                        Text("\(Game.shared.moduleOffered!.type.name()) Module \(Game.shared.moduleOfferPrice!)􀇷") //MARK: Add Module Purchasing
                            .font(.system(size: inch(0.2)))
                    case .tuesday:
                        Text("Moving and Firing are 50% cheaper today.\nTwo Event Cards are availible.")
                            .font(.system(size: inch(0.2)))
                    case .wednesday:
                        Grid(alignment: .center, horizontalSpacing: inch(0.05), verticalSpacing: 0) {
                            GridRow {
                                Image(systemName: "car.rear.road.lane.distance.\(max(1, min(tank.movementRange, 5)))")
                                    .font(.system(size: inch(0.2)))
                                Text("Movement Range")
                                    .font(.system(size: inch(0.2)))
                                    .lineLimit(1)
                                Text("\(UpgradeMovementRange(tankId: tank.uuid).metalCost)􀇷")
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
                                    default: ///`case 2, 1:
                                        return "gauge.with.dots.needle.100percent"
                                    }
                                }())
                                    .font(.system(size: inch(0.2)))
                                Text("Movement Efficiency")
                                    .font(.system(size: inch(0.2)))
                                    .lineLimit(1)
                                Text("\(UpgradeMovementCost(tankId: tank.uuid).metalCost)􀇷")
                                    .font(.system(size: inch(0.15)))
                                Text("\(tank.movementCost)􀵞 􀄫 \(tank.movementCost - 1)􀵞")
                                    .font(.system(size: inch(0.15)))
                            }
                        }
                    case .thursday:
                        EmptyView() // MARK: Implement Thrift
                    case .friday:
                        Grid(alignment: .center, horizontalSpacing: inch(0.1), verticalSpacing: 0) {
                            GridRow {
                                Image(systemName: "dot.scope")
                                    .font(.system(size: inch(0.2)))
                                Text("Weapon Range")
                                    .font(.system(size: inch(0.2)))
                                Text("\(UpgradeGunRange(tankId: tank.uuid).metalCost)􀇷")
                                    .font(.system(size: inch(0.2)))
                                Text("\(tank.gunRange)􀂒 􀄫 \(tank.gunRange + 1)􀂒")
                                    .font(.system(size: inch(0.2)))
                            }
                            
                            GridRow {
                                Image(systemName: "bandage")
                                    .font(.system(size: inch(0.2)))
                                Text("Weapon Damage")
                                    .font(.system(size: inch(0.2)))
                                Text("\(UpgradeGunDamage(tankId: tank.uuid).metalCost)􀇷")
                                    .font(.system(size: inch(0.2)))
                                Text("\(tank.gunDamage)􀲗 􀄫 \(tank.gunDamage + 5)􀲗")
                                    .font(.system(size: inch(0.2)))
                            }
                            
                            GridRow {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: inch(0.2)))
                                Text("Weapon Efficiency")
                                    .font(.system(size: inch(0.2)))
                                Text("\(UpgradeGunCost(tankId: tank.uuid).metalCost)􀇷")
                                    .font(.system(size: inch(0.2)))
                                Text("\(tank.gunCost)􀵞 􀄫 \(tank.gunCost - 1)􀵞")
                                    .font(.system(size: inch(0.2)))
                            }
                        }
                    }
                }
                .frame(width: inch(3.5), height: inch(2.5), alignment: .topLeading)
                Image(systemName: {
                    switch Game.shared.gameDay {
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
                }()) // image representing the gameDay
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

func fuelMeter(_ tank: Tank) -> MeterView {
    return MeterView(value: tank.fuel, max: 50, color: .green.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Fuel", icon: "fuelpump")
}

func metalMeter(_ tank: Tank) -> MeterView {
    return MeterView(value: tank.metal, max: 50, color: .yellow.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Metal", icon: "square.grid.2x2")
}

func healthMeter(_ tank: Tank) -> MeterView {
    return MeterView(value: tank.health, max: 100, color: .red.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Health", icon: "bolt.heart")
}

func defenseMeter(_ tank: Tank) -> MeterView {
    return MeterView(value: tank.defense, max: 10, color: .blue.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Defense", icon: "shield.lefthalf.filled")
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

struct RotatedDirectionOptions: View {
    let depth: Int
    var vector: [Direction]
    var action: ([Direction], Direction) -> Void
    var rotation: Direction
    
    struct RotationOptions: View {
        let label: String
        let action: ([Direction], Direction) -> Void
        let vector: [Direction]
        
        var body: some View {
            Menu(label) {
                Text("Choose a facing direction.")
                Button("􀄨 North") {
                    action(vector, .north)
                }
                Button("􀄩 South") {
                    action(vector, .south)
                }
                Button("􀄫 East") {
                    action(vector, .east)
                }
                Button("􀄪 West") {
                    action(vector, .west)
                }
            }
        }
    }
    
    var body: some View {
        if depth > 1  {
            Menu("􀄨 North") {
                RotatedDirectionOptions(depth: depth - 1, vector: vector + [.north], action: action, rotation: rotation)
            }
            Menu("􀄩 South") {
                RotatedDirectionOptions(depth: depth - 1, vector: vector + [.south], action: action, rotation: rotation)
            }
            Menu("􀄫 East") {
                RotatedDirectionOptions(depth: depth - 1, vector: vector + [.east], action: action, rotation: rotation)
            }
            Menu("􀄪 West") {
                RotatedDirectionOptions(depth: depth - 1, vector: vector + [.west], action: action, rotation: rotation)
            }
            if vector != [] {
                RotationOptions(label: "􀎫 Go!", action: action, vector: vector)
            }
        } else {
            RotationOptions(label: "􀄨 North", action: action, vector: vector + [.north])
            RotationOptions(label: "􀄩 South", action: action, vector: vector + [.south])
            RotationOptions(label: "􀄫 East", action: action, vector: vector + [.east])
            RotationOptions(label: "􀄪 West", action: action, vector: vector + [.west])
            if vector != [] {
                RotationOptions(label: "􀎫 Go!", action: action, vector: vector)
            }
        }
    }
}

struct VirtualStatusCard: View { //MARK: rework to match standard Status Card
    let tank: Tank
    let showBorderWarning: Bool
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                ZStack {
                    ControlPanelView(tank: tank)
                    TriangleViewport(coordinates: tank.coordinates!, viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, showBorderWarning: false, accessibilitySettings: tank.playerInfo.accessibilitySettings) //MARK: reference real value of ShowBorderWarning
                }
                ModuleView(module: tank.displayedModules[0])
                
                ModuleView(module: tank.displayedModules[2])
            }
            
                GridRow {
                    HStack(spacing: 0) {
                        fuelMeter(tank)
                        metalMeter(tank)
                        healthMeter(tank)
                        defenseMeter(tank)
                    }
                    ModuleView(module: tank.displayedModules[1])
                    
                    ModuleView(module: tank.displayedModules[3])
                }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        HStack(spacing: 0) {
            tank.statusCardConduitBack()
            tank.statusCardConduitFront()
        }
        HStack(spacing: 0) {
            tank.statusCardBack()
            tank.statusCardFront()
        }
    }
    .background(.white)
}
