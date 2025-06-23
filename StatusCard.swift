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
                    Text(tank.formattedDailyMessage())
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
                    Viewport(coordinates: tank.coordinates!, viewRenderSize: tank.radarRange, highDetailSightRange: tank.highDetailSightRange, lowDetailSightRange: tank.lowDetailSightRange, radarRange: tank.radarRange, showBorderWarning: showBorderWarning)
                        .frame(width: inch(4), height: inch(4), alignment: .center)
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
        VStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if tank.fuel >= tank.gunCost {
                        HStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(inch(0.395 / CGFloat(tank.radarRange * 2 + 1)))
                                    .foregroundColor(.white)
                                Image(systemName: "multiply")
                                    .frame(width: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), height: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)))
                                    .foregroundColor(.black)
                                    .font(.system(size: inch(3 / CGFloat(tank.radarRange * 2 + 1))))
                            }
                            .frame(width: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), height: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)))
                            Text("Draw an 􀅾 over a tile \(tank.gunRange) or fewer away from you to fire at it. Optionally, draw an arrow to indicate the missile’s path. Deals \(tank.gunDamage) 􀲗.\nCosts \(tank.gunCost) 􀵞.")
                                .font(.system(size: inch(0.1)))
                                .italic()
                                .foregroundColor(.black)
                        }
                    }
                    if tank.fuel >= tank.movementCost {
                        HStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(inch(0.395 / CGFloat(tank.radarRange * 2 + 1)))
                                    .foregroundColor(.white)
                                Image(systemName: "circle")
                                    .frame(width: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), height: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)))
                                    .foregroundColor(.black)
                                    .font(.system(size: inch(3 / CGFloat(tank.radarRange * 2 + 1))))
                            }
                            .frame(width: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), height: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)))
                            Text("Draw a 􀀀 over a tile \(tank.movementRange) or fewer away from you to move there. Optionally, draw an arrow to indicate your path.\nCosts \(tank.movementCost) 􀵞.")
                                .font(.system(size: inch(0.1)))
                                .italic()
                                .foregroundColor(.black)
                        }
                    }
                    if tank.metal >= 5 {
                        HStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(inch(0.395 / CGFloat(tank.radarRange * 2 + 1)))
                                    .foregroundColor(.white)
                                Image(systemName: "square")
                                    .frame(width: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), height: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)))
                                    .foregroundColor(.black)
                                    .font(.system(size: inch(3 / CGFloat(tank.radarRange * 2 + 1))))
                            }
                            .frame(width: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), height: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)))
                            Text("Draw a 􀂒 over a tile in the viewport adjacent to you to build a wall there.\nCosts 5 􀇷.")
                                .font(.system(size: inch(0.1)))
                                .italic()
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            if tank.fuel < (tank.movementCost + tank.gunCost) && tank.fuel >= tank.movementCost && tank.fuel >= tank.gunCost {
                Text("You cannot afford to both fire and move this turn.")
                    .font(.system(size: inch(0.1)))
                    .italic()
                    .foregroundColor(.black)
            }
            UpgradeOption(name: "Movement Range", currentValue: tank.movementRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.movementRange), tank: tank).metalCost(), unit: "􀂒", icon: "car.rear.road.lane.distance.\(min(tank.movementRange, 5))", tankMetal: tank.metal, costUnit: "􀇷")
            UpgradeOption(name: "Movement Cost", currentValue: tank.movementCost, minmaxValue: 1, upgradeIncrement: -1, upgradeCost: Action(.upgrade(.movementCost), tank: tank).metalCost(), unit: "􀵞", icon: "dollarsign.gauge.chart.leftthird.topthird.rightthird", tankMetal: tank.metal, costUnit: "􀇷")
            Spacer()
            UpgradeOption(name: "Gun Range", currentValue: tank.gunRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.gunRange), tank: tank).metalCost(), unit: "􀂒", icon: "headlight.high.beam", tankMetal: tank.metal, costUnit: "􀇷")
            UpgradeOption(name: "Gun Damage", currentValue: tank.gunDamage, minmaxValue: 50, upgradeIncrement: 5, upgradeCost: Action(.upgrade(.gunDamage), tank: tank).metalCost(), unit: "􀲗", icon: "bandage", tankMetal: tank.metal, costUnit: "􀇷")
            UpgradeOption(name: "Gun Cost", currentValue: tank.gunCost, minmaxValue: 7, upgradeIncrement: -1, upgradeCost: Action(.upgrade(.gunCost), tank: tank).metalCost(), unit: "􀵞", icon: "dollarsign.ring", tankMetal: tank.metal, costUnit: "􀇷")
            Spacer()
            if tank.highDetailSightRange < tank.lowDetailSightRange && tank.highDetailSightRange < tank.radarRange {
                UpgradeOption(name: "Camera Range", currentValue: tank.highDetailSightRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.highDetailSightRange), tank: tank).metalCost(), unit: "􀂒", icon: "camera", tankMetal: tank.metal, costUnit: "􀇷")
            }
            if tank.lowDetailSightRange < tank.radarRange {
                UpgradeOption(name: "LiDAR Range", currentValue: tank.lowDetailSightRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.lowDetailSightRange), tank: tank).metalCost(), unit: "􀂒", icon: "laser.burst", tankMetal: tank.metal, costUnit: "􀇷")
            }
            UpgradeOption(name: "RADAR Range", currentValue: tank.radarRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.radarRange), tank: tank).metalCost(), unit: "􀂒", icon: "antenna.radiowaves.left.and.right", tankMetal: tank.metal, costUnit: "􀇷")
            Spacer()
            if tank.health < 100 {
                UpgradeOption(name: "Repair Tank", currentValue: tank.health, minmaxValue: 100, upgradeIncrement: 5, upgradeCost: 3, unit: "%􀞽", icon: "wrench.and.screwdriver", tankMetal: tank.metal, costUnit: "􀇷")
            }
            Spacer()
            Spacer()
        }
    }
}

struct UpgradeOption: View {
    let name: String
    let currentValue: Int
    let minmaxValue: Int
    let upgradeIncrement: Int
    let upgradeCost: Int
    let unit: String
    let icon: String
    let tankMetal: Int
    let costUnit: String
    
    func checkUpgrade() -> Bool {
        if upgradeCost > tankMetal {
            return false
        }
        if upgradeIncrement > 0 {
            if currentValue + upgradeIncrement <= minmaxValue {
                return true
            } else {
                return false
            }
        } else {
            if currentValue + upgradeIncrement >= minmaxValue {
                return true
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        if checkUpgrade() {
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
        } else {
            EmptyView()
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

struct Viewport: View {
    let coordinates: Coordinates
    let viewRenderSize: Int
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    let showBorderWarning: Bool
    
    func getAppearenceAtLocation(_ localCoordinates: Coordinates) -> Appearance { //TODO: make this less horrible
        if localCoordinates.inBounds() {
            for tile in game.board.objects {
                if tile.coordinates != localCoordinates {
                    continue
                }
                if tile.coordinates!.level != coordinates.level {
                    continue
                }
                if tile is DeadTank {
                    continue
                }
                if tile.coordinates!.distanceTo(coordinates) <= radarRange {
                    if tile.coordinates!.distanceTo(coordinates) <= lowDetailSightRange {
                        if tile.coordinates!.distanceTo(coordinates) <= highDetailSightRange {
                            if tile.coordinates == localCoordinates {
                                return tile.appearance
                            }
                        } else {
                            if (tile.coordinates == localCoordinates) && !(tile.appearance.fillColor == .white) {
                                return Appearance(fillColor: tile.appearance.fillColor, strokeColor: tile.appearance.fillColor, symbolColor: tile.appearance.fillColor, symbol: "rectangle")
                            }
                        }
                    } else {
                        if (tile.coordinates == localCoordinates) && !(tile.appearance.fillColor == .white) {
                            let mysteryObject = Color(red: 0.4, green: 0.4, blue: 0.4)
                            return Appearance(fillColor: mysteryObject, strokeColor: mysteryObject, symbolColor: mysteryObject, symbol: "rectangle")
                        }
                    }
                }
            }
            if coordinates.distanceTo(localCoordinates) <= radarRange {
                if coordinates.distanceTo(localCoordinates) <= lowDetailSightRange {
                    if coordinates.distanceTo(localCoordinates) <= highDetailSightRange {
                        return Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "rectangle")
                    }
                    let fog = Color(red: 0.9, green: 0.9, blue: 0.9)
                    return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
                }
                let fog = Color(red: 0.8, green: 0.8, blue: 0.8)
                return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
            }
            let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
            return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
        } else {
            if localCoordinates.distanceTo(coordinates) <= radarRange {
                if localCoordinates.distanceTo(coordinates) <= lowDetailSightRange {
                    if showBorderWarning {
                        return Appearance(fillColor: .black, strokeColor: .black, symbolColor: .red, symbol: "exclamationmark.triangle.fill")
                    } else {
                        return Wall(coordinates: Coordinates(x: 0, y: 0)).appearance
                    }
                }
                let mysteryObject = Color(red: 0.4, green: 0.4, blue: 0.4)
                return Appearance(fillColor: mysteryObject, strokeColor: mysteryObject, symbolColor: mysteryObject, symbol: "rectangle")
            }
            let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
            return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(-coordinates.y - viewRenderSize...(-coordinates.y) + viewRenderSize, id: \.self) { y in
                    GridRow {
                        ForEach((coordinates.x - viewRenderSize)...(coordinates.x + viewRenderSize), id: \.self) { x in
                            @State var thisTile = game.board.objects.first(
                                where: { $0.coordinates == Coordinates(x: x, y: -y, level: coordinates.level) && !($0 is DeadTank)}) ?? nil
                            let thisTileAppearance = getAppearenceAtLocation(Coordinates(x: x, y: -y, level: coordinates.level))
                            TileView(appearance: thisTileAppearance)
                        }
                    }
                }
            }
            .frame(width: min(geometry.size.height, geometry.size.width), height: min(geometry.size.height, geometry.size.width), alignment: .center)
        }
    }
}

struct BasicTileView: View {
    let appearance: Appearance
    
    var body: some View {
        GeometryReader { geometry in
            let shortestLength = min(geometry.size.width, geometry.size.height, inch(1))
            ZStack {
                Rectangle()
                    .foregroundColor(appearance.fillColor)
                    .border(appearance.strokeColor, width: shortestLength / 10)
                    .cornerRadius(shortestLength / 10)
                Image(systemName: appearance.symbol)
                    .foregroundColor(appearance.symbolColor)
                    .font(.system(size: shortestLength / 2))
            }
            .frame(width: shortestLength, height: shortestLength, alignment: .center)
        }
    }
}

struct TileView: View {
    let appearance: Appearance
    var body: some View {
        BasicTileView(appearance: appearance)
            /*.contextMenu {
                if thisTile != nil {
                    if thisTile is Tank {
                        /*Button("􀎚 Print Status...") {
                         saveStatusCardsToPDF([thisTile as! Tank], doAlignmentCompensation: true, showBorderWarning: showBorderWarning)
                         }*/
                        Menu("Apply Action") { //TODO: make this use .disabled() insead of replacing with Text;
                            if (thisTile as! Tank).fuel >= (thisTile as! Tank).movementCost {
                                Menu("􀀀 Move") {
                                    DirectionOptions(depth: (thisTile as! Tank).movementRange, vector: []) {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.move($0), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("􀀀 Move")
                            }
                            if (thisTile as! Tank).fuel >= (thisTile as! Tank).gunCost {
                                Menu("􀅾 Fire") {
                                    DirectionOptions(depth: (thisTile as! Tank).gunRange, vector: []) {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.fire($0), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("􀅾 Fire")
                            }
                            if (thisTile as! Tank).metal >= 5 {
                                Menu("􀂒 Build Wall") {
                                    DirectionOptions(depth: 1, vector: []) {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.placeWall($0.first!), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("􀂒 Build Wall")
                            }
                            Section("􀇷 Upgrade") {
                                if (thisTile as! Tank).metal >= Action(.upgrade(.movementRange), tank: thisTile as! Tank).metalCost() {
                                    Button("􂊼 Movement Range") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.movementRange), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􂊼 Movement Range")
                                }
                                if (thisTile as! Tank).metal >= Action(.upgrade(.movementCost), tank: thisTile as! Tank).metalCost() {
                                    Button("􂧉 Movement Cost") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.movementCost), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􂧉 Movement Cost")
                                }
                                Spacer()
                                if (thisTile as! Tank).metal >= Action(.upgrade(.gunRange), tank: thisTile as! Tank).metalCost() {
                                    Button("􀾲 Gun Range") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.gunRange), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􀾲 Gun Range")
                                }
                                if (thisTile as! Tank).metal >= Action(.upgrade(.gunDamage), tank: thisTile as! Tank).metalCost() {
                                    Button("􀎓 Gun Damage") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.gunDamage), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􀎓 Gun Damage")
                                }
                                if (thisTile as! Tank).metal >= Action(.upgrade(.gunCost), tank: thisTile as! Tank).metalCost() {
                                    Button("􂮈 Gun Cost") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.gunCost), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􂮈 Gun Cost")
                                }
                                Spacer()
                                if Action(.upgrade(.highDetailSightRange), tank: thisTile as! Tank).isAlowed() {
                                    Button("􀌞 Camera Range") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.highDetailSightRange), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􀌞 Camera Range")
                                }
                                if Action(.upgrade(.lowDetailSightRange), tank: thisTile as! Tank).isAlowed() {
                                    Button("􂁝 LiDAR Range") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.lowDetailSightRange), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􂁝 LiDAR Range")
                                }
                                if Action(.upgrade(.radarRange), tank: thisTile as! Tank).isAlowed() {
                                    Button("􀖀 RADAR Range") {
                                        for object in game.board.objects {
                                            if object.id == thisTile.id {
                                                Action(.upgrade(.radarRange), tank: object as! Tank).run()
                                            }
                                        }
                                    }
                                } else {
                                    Text("􀖀 RADAR Range")
                                }
                                Spacer()
                                if (thisTile as! Tank).metal >= Action(.upgrade(.repair), tank: thisTile as! Tank).metalCost() { Button("􀤊 Repair") {
                                    for object in game.board.objects {
                                        if object.id == thisTile.id {
                                            Action(.upgrade(.repair), tank: object as! Tank).run()
                                        }
                                    }
                                }
                                } else {
                                    Text("􀤊 Repair")
                                }
                            }
                        }
                    }
                    Menu("􀋲 Attributes") {
                        if thisTile is Tank {
                            Section("   Player Demographics") {
                                Text("Name: \((thisTile! as! Tank).playerDemographics.firstName) \((thisTile! as! Tank).playerDemographics.lastName)")
                                Text("Delivery Location: \((thisTile! as! Tank).playerDemographics.deliveryType) \((thisTile! as! Tank).playerDemographics.deliveryNumber) in \((thisTile! as! Tank).playerDemographics.deliveryBuilding)")
                            }
                            Section("   Tank Attributes") {
                                Text("Fuel: \((thisTile! as! Tank).fuel)")
                                Text("Metal: \((thisTile! as! Tank).metal)")
                                Menu("Daily Message") {
                                    Text((thisTile! as! Tank).dailyMessage)
                                }
                                Menu("Upgrades") {
                                    Section("   Movement") {
                                        Text("Speed: \((thisTile! as! Tank).movementRange) Tiles/Turn")
                                        Text("Cost: \((thisTile! as! Tank).movementCost) Fuel")
                                    }
                                    Section("   Weaponry") {
                                        Text("Range: \((thisTile! as! Tank).gunRange) Tiles")
                                        Text("Damage: \((thisTile! as! Tank).gunDamage) Health")
                                        Text("Cost: \((thisTile! as! Tank).gunCost) Fuel")
                                    }
                                    Section("   Sight Range") {
                                        Text("High Detail: \((thisTile! as! Tank).highDetailSightRange) Tiles")
                                        Text("Low Detail: \((thisTile! as! Tank).lowDetailSightRange) Tiles")
                                        Text("Radar: \((thisTile! as! Tank).radarRange) Tiles")
                                    }
                                }
                            }
                        }
                        Section("   General Attributes") {
                            Text("XY: \(thisTile!.coordinates.x), \(thisTile!.coordinates.y)")
                            Text("Health: \(thisTile!.health)")
                            Text("Defense: \(thisTile!.defense)")
                            Text("Fuel Dropped: \(thisTile!.fuelDropped)")
                            Text("Metal Dropped: \(thisTile!.metalDropped)")
                        }
                    }
                    Button("􀈑 Delete") {
                        game.board.objects.removeAll(where: {
                            $0 == thisTile})
                    }
                    Menu("􀇳 Admin Move") {
                        DirectionOptions(depth: 3, vector: []) {
                            for index in game.board.objects.indices {
                                if game.board.objects[index] == thisTile {
                                    game.board.objects[index].move($0)
                                }
                            }
                        }
                        Button("􀄿 Increase Level") {
                            for index in game.board.objects.indices {
                                if game.board.objects[index] == thisTile {
                                    game.board.objects[index].coordinates.level += 1
                                }
                            }
                        }
                        Button("􀅀 Decrease Level") {
                            for index in game.board.objects.indices {
                                if game.board.objects[index] == thisTile {
                                    game.board.objects[index].coordinates.level -= 1
                                }
                            }
                        }
                    }
                }/* else {
                  Button("􀂒 Add Wall") {
                  game.board.objects.append(Wall(coordinates: Coordinates(x: x, y: -y)))
                  }
                  Button("􀑉 Add Gift") {
                  let totalReward: Int = 20
                  let metalReward: Int = Int.random(in: 0...totalReward)
                  let fuelReward: Int = totalReward - metalReward
                  game.board.objects.append(Gift(coordinates: Coordinates(x: x, y: -y), fuelReward: fuelReward, metalReward: metalReward))
                  }
                  Button("􀭉 Add Placeholder") {
                  game.board.objects.append(Placeholder(coordinates: Coordinates(x: x, y: -y)))
                  }
                  }*/ //TODO: Make these reference coordinates correctly
            }*///TODO: Make the Context Menus actually work, assuming they are not replaced with a new system
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

struct VirtualStatusCard: View {
    let tank: Tank
    let showBorderWarning: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Viewport(coordinates: tank.coordinates ?? Coordinates(x: 0, y: 0, level: 0), viewRenderSize: tank.radarRange, highDetailSightRange: tank.highDetailSightRange, lowDetailSightRange: tank.lowDetailSightRange, radarRange: tank.radarRange, showBorderWarning: showBorderWarning)
                    .frame(width: inch(4), height: inch(4), alignment: .center)
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

