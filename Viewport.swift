//
//  Viewport.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/2/25.
//

import Foundation
import SwiftUI

struct SquareViewport: View {
    let coordinates: Coordinates
    let viewRenderSize: Int
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    let accessibilitySettings: AccessibilitySettings
    
    @Binding var selectedObject: (any BoardObject)?
    
    @ObservedObject var game: Game
    
    var body: some View {
        GeometryReader { geometry in
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(((-viewRenderSize)...viewRenderSize).reversed(), id: \.self) { upOffset in
                    GridRow {
                        ForEach(((-viewRenderSize)...viewRenderSize), id: \.self) { rightOffset in
                            TileView(centerCoordinates: coordinates, highDetailSightRange: highDetailSightRange, lowDetailSightRange: lowDetailSightRange, radarRange: radarRange, coordinates: coordinates.viewOffset(right: rightOffset, up: upOffset), accessibilitySettings: accessibilitySettings, selectedObject: $selectedObject, game: game)
                        }
                    }
                }
            }
            .frame(width: min(geometry.size.height, geometry.size.width), height: min(geometry.size.height, geometry.size.width), alignment: .center)
        }
    }
}

struct TriangleViewport: View {
    let coordinates: Coordinates
    let viewRenderSize: Int
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    let accessibilitySettings: AccessibilitySettings
    
    @Binding var selectedObject: (any BoardObject)?
    
    @ObservedObject var game: Game
    
    var body: some View {
        GeometryReader { geometry in
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(((-1)...viewRenderSize).reversed(), id: \.self) { upOffset in
                    GridRow {
                        ForEach(((-viewRenderSize)...1), id: \.self) { rightOffset in
                            if rightOffset - upOffset + viewRenderSize > 1 {
                                if upOffset == -1 &&  rightOffset + viewRenderSize == 1 {
                                    Text("X: \(coordinates.x)")
                                        .font(.system(size: inch(CGFloat(Double(1.5) / (Double(viewRenderSize) + 2)))))
                                        .foregroundStyle(.black)
                                } else if upOffset == -1 && rightOffset + viewRenderSize == 2 {
                                    Text("Y: \(coordinates.y)")
                                        .font(.system(size: inch(CGFloat(Double(1.5) / (Double(viewRenderSize) + 2)))))
                                        .foregroundStyle(.black)
                                } else if upOffset - viewRenderSize == -1 && rightOffset == 1 {
                                    Text(coordinates.rotation.letter)
                                        .font(.system(size: inch(CGFloat(Double(3) / (Double(viewRenderSize) + 2)))))
                                        .foregroundStyle(.black)
                                } else if upOffset - viewRenderSize == -2 && rightOffset == 1 {
                                    Image(systemName: "location.north.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(inch(CGFloat(Double(0.5) / (Double(viewRenderSize) + 2))))
                                        .rotationEffect(coordinates.rotation.angle)
                                        .foregroundStyle(.black)
                                } else {
                                    TileView(centerCoordinates: coordinates, highDetailSightRange: highDetailSightRange, lowDetailSightRange: lowDetailSightRange, radarRange: radarRange, coordinates: coordinates.viewOffset(right: rightOffset, up: upOffset), accessibilitySettings: accessibilitySettings, selectedObject: $selectedObject, game: game)
                                }
                            } else {
                                BasicTileView(appearance: nil, accessibilitySettings: accessibilitySettings)
                            }
                        }
                    }
                }
            }
            .frame(width: min(geometry.size.height, geometry.size.width), height: min(geometry.size.height, geometry.size.width), alignment: .center)
        }
    }
}

struct BasicTileView: View {
    let appearance: Appearance?
    let accessibilitySettings: AccessibilitySettings
    
    var body: some View {
        GeometryReader { geometry in
            let shortestLength = min(geometry.size.width, geometry.size.height)
            ZStack {
                if appearance != nil {
                    RoundedRectangle(cornerRadius: shortestLength * 0.15)
                        .foregroundColor(accessibilitySettings.highContrast ? .black : .gray)
                }
                RoundedRectangle(cornerRadius: shortestLength * 0.15)
                    .foregroundColor(appearance?.strokeColor ?? appearance?.fillColor ?? Color.white.opacity(0))
                    .frame(width: shortestLength * (accessibilitySettings.highContrast ? 0.95 : 0.99), height: shortestLength * (accessibilitySettings.highContrast ? 0.95 : 0.99))
                
                RoundedRectangle(cornerRadius: shortestLength * 0.05)
                    .foregroundColor(appearance?.fillColor ?? Color.white.opacity(0))
                    .frame(width: shortestLength * 0.8, height: shortestLength * 0.8, alignment: .center)
                
                if appearance?.symbolColor == nil {
                    Image(systemName: appearance?.symbol ?? "")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .scaledToFit()
                        .frame(width: shortestLength * 0.7, height: shortestLength * 0.7, alignment: .center)
                } else {
                    Image(systemName: appearance?.symbol ?? "")
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(appearance?.symbolColor ?? Color.white.opacity(0))
                        .frame(width: shortestLength * 0.7, height: shortestLength * 0.7, alignment: .center)
                }
            }
            .frame(width: shortestLength, height: shortestLength, alignment: .center)
            .contrast(accessibilitySettings.highContrast ? 3.0 : 1.0)
        }
    }
}

struct TileView: View {
    let centerCoordinates: Coordinates
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    let coordinates: Coordinates
    let accessibilitySettings: AccessibilitySettings
    
    var thisTile: (any BoardObject)? { game.board.objects.first(where: { $0.coordinates == coordinates }) }
    
    @Binding var selectedObject: (any BoardObject)?
    
    @ObservedObject var game: Game
    
    func getAppearenceAtLocation() -> Appearance { #warning("Please make this less horrible.")
        if game.board.inBounds(at: coordinates) {
            if coordinates.distanceTo(centerCoordinates) <= radarRange {
                if coordinates.distanceTo(centerCoordinates) <= lowDetailSightRange {
                    if coordinates.distanceTo(centerCoordinates) <= highDetailSightRange {
                        //fully rendered
                        return game.board.appearanceMap[coordinates] ?? Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "rectangle")
                    } else {
                        //only in lidar and radar range
                        if !(game.board.appearanceMap[coordinates]?.strokeColor == .white) { //skips 'small' objects
                            if game.board.appearanceMap[coordinates] != nil {
                                return Appearance(fillColor: game.board.appearanceMap[coordinates]!.fillColor, symbolColor: game.board.appearanceMap[coordinates]!.fillColor, symbol: "rectangle")
                            } else {
                                let fog = Color(red: 0.9, green: 0.9, blue: 0.9)
                                return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle") //greyer if not in full range
                            }
                        }
                    }
                } else {
                    //only in radar range
                    if game.board.appearanceMap[coordinates] != nil {
                        if !(game.board.appearanceMap[coordinates]?.strokeColor == .white) { //skips 'small' objects
                            let mysteryObjectColor = Color(red: 0.4, green: 0.4, blue: 0.4) //color for an object only in Radar Range
                            return Appearance(fillColor: mysteryObjectColor, symbolColor: mysteryObjectColor, symbol: "rectangle")
                        }
                    }
                    let fog = Color(red: 0.8, green: 0.8, blue: 0.8)
                    return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle") //greyer if only in radar range
                }
            }
            let fog = Color.white
            return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle")
        } else {
        //renderer for out of bounds tiles
        if coordinates.distanceTo(centerCoordinates) <= radarRange {
            if coordinates.distanceTo(centerCoordinates) <= lowDetailSightRange {
                return game.board.showBorderWarning ? Appearance(fillColor: .gray, symbolColor: .red, symbol: "exclamationmark.triangle.fill") : Appearance(fillColor: .gray, symbolColor: .gray, symbol: "rectangle")
            }
            let mysteryObject = Color(red: 0.4, green: 0.4, blue: 0.4)
            return Appearance(fillColor: mysteryObject, symbolColor: mysteryObject, symbol: "rectangle")
        }
        let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
        return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle")
    }
}
    
    var body: some View {
        BasicTileView(appearance: getAppearenceAtLocation(), accessibilitySettings: accessibilitySettings)
            .contextMenu {
                if thisTile != nil {
                    Button("Context menu for \(coordinates.description)") {}
                } else {
                    Button("􀂒 Add Wall") {
                        game.board.walls.append(Wall(coordinates: coordinates))
                    }
                    Button("􁗝 Add Ore Deposit") {
                        game.board.oreDeposits.append(OreDeposit(coordinates: coordinates))
                    }
                    Button("􀭉 Add New Tank") {
                        game.board.tanks.append(Tank(in: game))
                    }
                }
            }
            .onTapGesture(count: 1) {
                selectedObject = thisTile
            }
            .onTapGesture(count: 2) {
                game.board.oreDeposits.removeAll(where: { $0 === thisTile as? OreDeposit })
                game.board.walls.append(Wall(coordinates: coordinates))
            }
    }
}

let selectedObjectBindingDefault = Binding<(any BoardObject)?>(get: { nil }, set: { _ in print("An attempt to edit the nil binding was made.") })

#Preview {
    VStack {
        TriangleViewport(coordinates: Coordinates(x: 0, y: 0, rotation: .south), viewRenderSize: 7, highDetailSightRange: 100, lowDetailSightRange: 200, radarRange: 300, accessibilitySettings: AccessibilitySettings(), selectedObject: selectedObjectBindingDefault, game: previewCanvasGame)
            .frame(width: inch(4), height: inch(4))
        SquareViewport(coordinates: Coordinates(x: 0, y: 0, rotation: .south), viewRenderSize: 4, highDetailSightRange: 1, lowDetailSightRange: 2, radarRange: 3, accessibilitySettings: AccessibilitySettings(), selectedObject: selectedObjectBindingDefault, game: previewCanvasGame)
            .frame(width: inch(4), height: inch(4))
    }
    .background(.white)
}
