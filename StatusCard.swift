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
            VStack {
                VStack {
                    Spacer(minLength: inch(1.25))
                    Text(tank.formattedDailyMessage())
                        .font(.system(size: inch(0.15)))
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .bottomLeading)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .fontDesign(.monospaced)
                }
                .rotationEffect(Angle(degrees: 90))
                .frame(width: inch(5.5), height: inch(4.25), alignment: .center)
                Spacer()
                Spacer(minLength: inch(4.25))
                
            }
            VStack {
                VStack {
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
                .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
                VStack {
                    Text(tank.playerDemographics.deliveryBuilding)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .fontWeight(.light)
                        .font(.system(size: inch(0.35)))
                    HStack {
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
                .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
            }
            VStack {
                HStack {
                    Image("")
                        .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
                    MeterView(value: tank.fuel, max: 30, color: .green, label: "fuel", icon: "fuelpump")
                        .padding(.horizontal, -4)
                    Spacer()
                }
                .padding(.vertical, -4)
                HStack {
                    Spacer()
                    MeterView(value: tank.health, max: 100, color: .red, label: "health", icon: "bolt.heart")
                        .padding(.horizontal, -4)
                    Image("")
                        .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
                }
                .padding(.vertical, -4)
            }
        }
    }
}

struct StatusCardBack: View {
    let tank: Tank
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        MeterView(value: tank.fuel, max: 30, color: .green, label: "fuel", icon: "fuelpump")
                            .padding(.horizontal, -4)
                        MeterView(value: tank.metal, max: 30, color: .yellow, label: "metal", icon: "square.grid.2x2")
                            .padding(.horizontal, -4)
                    }
                    .frame(width: inch(1.25), height: inch(4.25), alignment: .center)
                    Viewport(coordinates: tank.coordinates, cellSize: inch(4.25 / CGFloat(tank.radarRange * 2 + 1)), viewRenderSize: tank.radarRange, highDetailSightRange: tank.highDetailSightRange, lowDetailSightRange: tank.lowDetailSightRange, radarRange: tank.radarRange)
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .center)
                }
                .frame(width: inch(5.5), height: inch(4.25), alignment: .top)
                HStack {
                    ControlPanelView(tank: tank)
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .topLeading)
                    HStack {
                        MeterView(value: tank.defense, max: 30, color: .blue, label: "defense", icon: "shield.righthalf.filled")
                            .padding(.horizontal, -4)
                        MeterView(value: tank.health, max: 100, color: .red, label: "health", icon: "bolt.heart")
                            .padding(.horizontal, -4)
                    }
                    .frame(width: inch(1.25), height: inch(4.25), alignment: .center)
                }
                .frame(width: inch(5.5), height: inch(4.25), alignment: .bottom)
            }
        }
    }
}

struct ControlPanelView: View {
    let tank: Tank
    var body: some View {
        VStack {
            HStack {
                if tank.fuel >= tank.gunCost {
                    HStack {
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
                        Text("Draw an 􀅾 over a square \(tank.gunRange) or fewer away from you to fire at it. Optionally, draw an arrow to indicate the missile’s path.\nCosts \(tank.gunCost) fuel.")
                            .font(.system(size: inch(0.1)))
                            .italic()
                            .padding(.horizontal, -4)
                            .foregroundColor(.black)
                    }
                    .frame(height: inch(1))
                }
                
                if tank.fuel >= tank.movementCost {
                    HStack {
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
                        Text("Draw a 􀀀 in the viewport \(tank.movementRange) or fewer away from you to move there. Optionally, draw an arrow to indicate your path.\nCosts \(tank.movementCost) fuel.")
                            .font(.system(size: inch(0.1)))
                            .italic()
                            .foregroundColor(.black)
                    }
                    .frame(height: inch(1))
                }
                
                if tank.metal >= 10 {
                    HStack {
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
                        .padding(.horizontal, -4)
                        Text("Draw a 􀂒 over a tile in the viewport adjacent to your current position to build a wall there.\nCosts 10 metal.")
                            .font(.system(size: inch(0.1)))
                            .italic()
                            .foregroundColor(.black)
                    }
                    .frame(height: inch(1))
                }
                
            }
            .frame(width: inch(4.25), height: inch(1))
            VStack {
                UpgradeOption(name: "Movement Range", currentValue: tank.movementRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.movementRange), tank: tank).metalCost(), unit: "􀂒", icon: "car.rear.road.lane.distance.\(min(tank.movementRange, 5))", tankMetal: tank.metal)
                UpgradeOption(name: "Movement Cost", currentValue: tank.movementCost, minmaxValue: 1, upgradeIncrement: -1, upgradeCost: Action(.upgrade(.movementCost), tank: tank).metalCost(), unit: "􀵞", icon: "dollarsign.gauge.chart.leftthird.topthird.rightthird", tankMetal: tank.metal)
                Spacer()
                UpgradeOption(name: "Gun Range", currentValue: tank.gunRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.gunRange), tank: tank).metalCost(), unit: "􀂒", icon: "headlight.high.beam", tankMetal: tank.metal)
                UpgradeOption(name: "Gun Damage", currentValue: tank.gunDamage, minmaxValue: 50, upgradeIncrement: 5, upgradeCost: Action(.upgrade(.gunDamage), tank: tank).metalCost(), unit: "%􀞽", icon: "bandage", tankMetal: tank.metal)
                UpgradeOption(name: "Gun Cost", currentValue: tank.gunCost, minmaxValue: 7, upgradeIncrement: -1, upgradeCost: Action(.upgrade(.gunCost), tank: tank).metalCost(), unit: "􀵞", icon: "dollarsign.ring", tankMetal: tank.metal)
                Spacer()
                if tank.highDetailSightRange < tank.lowDetailSightRange && tank.highDetailSightRange < tank.radarRange {
                    UpgradeOption(name: "Camera Range", currentValue: tank.highDetailSightRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.highDetailSightRange), tank: tank).metalCost(), unit: "􀂒", icon: "camera", tankMetal: tank.metal)
                }
                if tank.lowDetailSightRange < tank.radarRange {
                    UpgradeOption(name: "LiDAR Range", currentValue: tank.lowDetailSightRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.lowDetailSightRange), tank: tank).metalCost(), unit: "􀂒", icon: "laser.burst", tankMetal: tank.metal)
                }
                UpgradeOption(name: "RADAR Range", currentValue: tank.radarRange, minmaxValue: 7, upgradeIncrement: 1, upgradeCost: Action(.upgrade(.radarRange), tank: tank).metalCost(), unit: "􀂒", icon: "antenna.radiowaves.left.and.right", tankMetal: tank.metal)
                Spacer()
            }
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
            HStack {
                Image(systemName: icon)
                    .font(.system(size: inch(0.2)))
                    .frame(width: inch(0.4))
                    .foregroundColor(.black)
                Text("\(name): \(currentValue) \(unit) 􁉂 \(currentValue + upgradeIncrement) \(unit) (Costs \(upgradeCost)􀇷)")
                    .font(.system(size: inch(0.2)))
                    .foregroundColor(.black)
                    .padding(.leading, inch(0.1))
                Spacer()
            }
            .padding(.vertical, inch(0.04))
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
                    .frame(width: inch(0.5), height: inch((CGFloat(min(value, max)) / CGFloat(max) * 4.25)), alignment: .bottom)
                VStack {
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
                .frame(width: inch(0.5), height: inch((CGFloat(min(value, max)) / CGFloat(max) * 4.25)), alignment: .bottom)
            }
            .frame(width: inch(0.625), height: inch(4.25), alignment: .bottom)
        }
    }
}

struct Viewport: View {
    let coordinates: Coordinates
    let cellSize: CGFloat
    let viewRenderSize: Int
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    
    func getAppearenceAtLocation(_ localCoordinates: Coordinates) -> Appearance {
        if localCoordinates.inBounds() {
            for tile in board.objects {
                if tile.coordinates != localCoordinates {
                    continue
                }
                if tile.coordinates.distanceTo(coordinates) <= radarRange {
                    if tile.coordinates.distanceTo(coordinates) <= lowDetailSightRange {
                        if tile.coordinates.distanceTo(coordinates) <= highDetailSightRange {
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
                    return Wall(coordinates: Coordinates(x: 0, y: 0)).appearance
                }
                let mysteryObject = Color(red: 0.4, green: 0.4, blue: 0.4)
                return Appearance(fillColor: mysteryObject, strokeColor: mysteryObject, symbolColor: mysteryObject, symbol: "rectangle")
            }
            let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
            return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
        }
    }
    
    var body: some View {
        HStack {
            ForEach(coordinates.x - viewRenderSize...coordinates.x + viewRenderSize, id: \.self) { x in
                VStack {
                    ForEach((-coordinates.y - viewRenderSize)...(-coordinates.y + viewRenderSize), id: \.self) { y in
                        @State var thisTile = board.objects.first(
                            where: { $0.coordinates == Coordinates(x: x, y: -y) }) ?? nil
                        ZStack {
                            let thisTileAppearance = getAppearenceAtLocation(Coordinates(x: x, y: -y))
                            Rectangle()
                                .foregroundColor(thisTileAppearance.fillColor)
                                .frame(width: cellSize, height: cellSize)
                                .border(thisTileAppearance.strokeColor, width: cellSize / 10)
                                .cornerRadius(cellSize / 10)
                            Image(systemName: thisTileAppearance.symbol)
                                .foregroundColor(thisTileAppearance.symbolColor)
                                .frame(width: cellSize, height: cellSize)
                                .font(.system(size: cellSize / 2))
                        }
                        .frame(width: cellSize, height: cellSize)
                        .padding(.vertical, -4)
                        .contextMenu {
                            if thisTile != nil {
                                if thisTile is Tank {
                                    Button("􀎚 Print Status...") {
                                        saveStatusCardsToPDF([thisTile! as! Tank])
                                    }
                                    Menu("Apply Action") {
                                        Menu("􀀀 Move") {
                                            DirectionOptions(depth: (thisTile as! Tank).movementRange, vector: []) {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.move($0), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                        }
                                        Menu("􀅾 Fire") {
                                            DirectionOptions(depth: (thisTile as! Tank).gunRange, vector: []) {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.fire($0), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                        }
                                        Menu("􀂒 Build Wall") {
                                            DirectionOptions(depth: 1, vector: []) {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.placeWall($0.first!), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                        }
                                        Menu("􀇷 Upgrade") {
                                            Button("􂊼 Movement Range") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.movementRange), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􂧉 Movement Cost") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.movementCost), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􀾲 Gun Range") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.gunRange), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􀎓 Gun Damage") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.gunDamage), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􂮈 Gun Cost") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.gunCost), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􀌞 Camera Range") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.highDetailSightRange), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􂁝 LiDAR Range") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.lowDetailSightRange), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
                                            }
                                            Button("􀖀 RADAR Range") {
                                                for object in board.objects {
                                                    if object == thisTile {
                                                        Action(.upgrade(.radarRange), tank: object as! Tank).run()
                                                    }
                                                }
                                                runGameTick()
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
                                    board.objects.removeAll(where: {
                                        $0 == thisTile})
                                }
                            } else {
                                Button("􀂒 Add Wall") {
                                    board.objects.append(Wall(coordinates: Coordinates(x: x, y: -y)))
                                }
                                Button("􀑉 Add Gift") {
                                    let totalReward: Int = 20
                                    let metalReward: Int = Int.random(in: 0...totalReward)
                                    let fuelReward: Int = totalReward - metalReward
                                    board.objects.append(Gift(coordinates: Coordinates(x: x, y: -y), fuelReward: fuelReward, metalReward: metalReward))
                                }
                                Button("􀭉 Add Placeholder") {
                                    board.objects.append(TankPlaceholder(coordinates: Coordinates(x: x, y: -y)))
                                }
                                
                            }
                        }
                        .onTapGesture {
                            if thisTile == nil {
                                board.objects.append(Wall(coordinates: Coordinates(x: x, y: -y)))
                            } else if thisTile is Wall {
                                board.objects.removeAll(where: {
                                    $0 == thisTile})
                                let totalReward: Int = 20
                                let metalReward: Int = Int.random(in: 0...totalReward)
                                let fuelReward: Int = totalReward - metalReward
                                board.objects.append(Gift(coordinates: Coordinates(x: x, y: -y), fuelReward: fuelReward, metalReward: metalReward))
                            } else if thisTile is Gift {
                                board.objects.removeAll(where: {
                                    $0 == thisTile})
                                board.objects.append(TankPlaceholder(coordinates: Coordinates(x: x, y: -y)))
                            } else if thisTile is TankPlaceholder {
                                board.objects.removeAll(where: {
                                    $0 == thisTile})
                                for object in board.objects {
                                    if object is Tank {
                                        if !object.coordinates.inBounds() {
                                            object.coordinates = Coordinates(x: x, y: -y)
                                            break
                                        }
                                        continue
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: cellSize, height: cellSize * CGFloat(viewRenderSize))
                .padding(.horizontal, -4)
            }
        }
        .frame(width: cellSize * CGFloat(viewRenderSize), height: cellSize * CGFloat(viewRenderSize))
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
    var body: some View {
        VStack {
            Viewport(coordinates: tank.coordinates, cellSize: inch(4.25 / CGFloat(tank.radarRange * 2 + 1)), viewRenderSize: tank.radarRange, highDetailSightRange: tank.highDetailSightRange, lowDetailSightRange: tank.lowDetailSightRange, radarRange: tank.radarRange)
                .frame(width: inch(4.25), height: inch(4.25), alignment: .center)
            HStack {
                ControlPanelView(tank: tank)
                    .frame(width: inch(4.25), height: inch(4.25), alignment: .top)
                MeterView(value: tank.fuel, max: 30, color: .green, label: "fuel", icon: "fuelpump")
                    .padding(.horizontal, -4)
                MeterView(value: tank.metal, max: 30, color: .yellow, label: "metal", icon: "square.grid.2x2")
                    .padding(.horizontal, -4)
                MeterView(value: tank.defense, max: 30, color: .blue, label: "defense", icon: "shield.righthalf.filled")
                    .padding(.horizontal, -4)
                MeterView(value: tank.health, max: 100, color: .red, label: "health", icon: "bolt.heart")
                    .padding(.horizontal, -4)
            }
        }
        .frame(width: inch(8.5))
    }
}

#Preview("Status Card") {
    let example = Tank(appearance: Appearance(fillColor: .yellow, strokeColor: .gray, symbolColor: .orange, symbol: "printer"), coordinates: Coordinates(x: 0, y: 0), playerDemographics: PlayerDemographics(firstName: "Rodriguezz", lastName: "Appleseed-Bonjoir", deliveryBuilding: "Apple Park, Cuperino, CA", deliveryType: "Window", deliveryNumber: "101"), fuel: 16, metal: 14, health: 100, defense: 18, movementCost: 10, movementRange: 1, gunRange: 1, gunDamage: 5, gunCost: 10, highDetailSightRange: 1, lowDetailSightRange: 1, radarRange: 2, dailyMessage: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ligula quam, semper quis fringilla nec, elementum eget magna. Donec finibus auctor efficitur. Sed vulputate est sed augue mollis malesuada. Vestibulum dictum molestie congue. Praesent justo lorem, convallis quis ex porttitor, porta posuere turpis. Aliquam a tristique est. Praesent ut felis et mi suscipit porttitor. Aenean justo risus, luctus dignissim fringilla ac, congue consequat velit. In hac habitasse platea dictumst. Maecenas a nisi a sapien gravida vulputate sit amet vel mauris. Nullam lectus massa, hendrerit at viverra auctor, aliquam eget augue. Sed nec arcu ipsum. Quisque pulvinar semper augue id ornare. Curabitur finibus nisi at semper scelerisque. Mauris dictum laoreet ullamcorper.
""", false)
    HSplitView {
        StatusCardFront(tank: example)
            .frame(width: inch(5.5), height: inch(8.5))
        Rectangle()
        StatusCardBack(tank: example)
            .frame(width: inch(5.5), height: inch(8.5))
    }
    .frame(width: inch(11.02), height: inch(8.5))
}
