//
//  Viewport.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/2/25.
//

import Foundation
import SwiftUI

struct Viewport: View {
    let coordinates: Coordinates
    let viewRenderSize: Int
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    let showBorderWarning: Bool
    
    func getAppearenceAtLocation(_ localCoordinates: Coordinates) -> Appearance { //TODO: make this less horrible
        if localCoordinates.inBounds() {
            for tile in game.board.objects { //if there is an object, it will be rendered here
                if tile.coordinates != localCoordinates { //first and most important check: that this tile is in the correct location to be rendered.
                    continue //skips to next object in the loop
                }
                if tile.coordinates!.distanceTo(coordinates) <= radarRange {
                    if tile.coordinates!.distanceTo(coordinates) <= lowDetailSightRange {
                        if tile.coordinates!.distanceTo(coordinates) <= highDetailSightRange {
                            //fully rendered
                            return tile.appearance
                        } else {
                            //only in lidar and radar range
                            if !(tile.appearance.fillColor == .white) { //skips 'small' objects
                                return Appearance(fillColor: tile.appearance.fillColor, strokeColor: tile.appearance.fillColor, symbolColor: tile.appearance.fillColor, symbol: "rectangle")
                            }
                        }
                    } else {
                        //only in radar range
                        if !(tile.appearance.fillColor == .white) { //skips 'small' objects
                            let mysteryObjectColor = Color(red: 0.4, green: 0.4, blue: 0.4) //color for an object only in Radar Range
                            return Appearance(fillColor: mysteryObjectColor, strokeColor: mysteryObjectColor, symbolColor: mysteryObjectColor, symbol: "rectangle")
                        }
                    }
                }
            }
            //renders if there is nothing there, but still requires inbounds
            if coordinates.distanceTo(localCoordinates) <= radarRange {
                if coordinates.distanceTo(localCoordinates) <= lowDetailSightRange {
                    if coordinates.distanceTo(localCoordinates) <= highDetailSightRange {
                        return Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "rectangle") //pure white if in full range
                    }
                    let fog = Color(red: 0.9, green: 0.9, blue: 0.9)
                    return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle") //greyer if not in full range
                }
                let fog = Color(red: 0.8, green: 0.8, blue: 0.8)
                return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle") //greyer if only in radar range
            }
            let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
            return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle") // greyest if out of range
        } else {
            //renderer for out of bounds tiles
            if localCoordinates.distanceTo(coordinates) <= radarRange {
                if localCoordinates.distanceTo(coordinates) <= lowDetailSightRange {
                    return showBorderWarning ? Appearance(fillColor: .black, strokeColor: .black, symbolColor: .red, symbol: "exclamationmark.triangle.fill") : Wall(coordinates: Coordinates(x: 0, y: 0, level: 0)).appearance
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
                RoundedRectangle(cornerRadius: shortestLength * 0.15)
                    .foregroundColor(appearance.strokeColor)
                
                RoundedRectangle(cornerRadius: shortestLength * 0.05)
                    .foregroundColor(appearance.fillColor)
                    .frame(width: shortestLength * 0.8, height: shortestLength * 0.8, alignment: .center)
                    
                Image(systemName: appearance.symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(appearance.symbolColor)
                    .frame(width: shortestLength * 0.7, height: shortestLength * 0.7, alignment: .center)
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

#Preview {
    TileView(appearance: Appearance(fillColor: .red, strokeColor: .green, symbolColor: .blue, symbol: "tree.circle"))
}
