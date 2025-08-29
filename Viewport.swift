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
    let showBorderWarning: Bool
    let accessibilitySettings: AccessibilitySettings
    
    var body: some View {
        GeometryReader { geometry in
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(((-viewRenderSize)...viewRenderSize).reversed(), id: \.self) { upOffset in
                    GridRow {
                        ForEach(((-viewRenderSize)...viewRenderSize), id: \.self) { rightOffset in
                            TileView(coordinates: coordinates, highDetailSightRange: highDetailSightRange, lowDetailSightRange: lowDetailSightRange, radarRange: radarRange, showBorderWarning: showBorderWarning, localCoordinates: coordinates.viewOffset(right: rightOffset, up: upOffset), accessibilitySettings: accessibilitySettings)
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
    let showBorderWarning: Bool
    let accessibilitySettings: AccessibilitySettings
    
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
                                    TileView(coordinates: coordinates, highDetailSightRange: highDetailSightRange, lowDetailSightRange: lowDetailSightRange, radarRange: radarRange, showBorderWarning: showBorderWarning, localCoordinates: coordinates.viewOffset(right: rightOffset, up: upOffset), accessibilitySettings: accessibilitySettings)
                                }
                            } else {
                                BasicTileView(appearance: Appearance(fillColor: Color(hex: 0x000000, alpha: 0), symbol: ""), accessibilitySettings: accessibilitySettings)
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
                RoundedRectangle(cornerRadius: shortestLength * 0.15)
                    .foregroundColor(appearance?.strokeColor ?? appearance?.fillColor ?? Color.white.opacity(0))
                
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
            .contrast(accessibilitySettings.highContrast ? 1 : 1.0)
        }
    }
}

struct TileView: View {
    let coordinates: Coordinates
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    let showBorderWarning: Bool
    let localCoordinates: Coordinates
    let accessibilitySettings: AccessibilitySettings
    
    func getAppearenceAtLocation() -> Appearance { //MARK: make this less horrible
        if localCoordinates.inBounds() {
            for tile in game.board.objects { //if there is an object, it will be rendered here
                if tile.coordinates != localCoordinates { //first and most important check: that this tile is in the correct location to be rendered.
                    continue //skips to next object in the loop
                }
                if tile.appearance == nil { //tile is invisible
                    continue //skip rendering invisible tiles
                }
                if tile.coordinates!.distanceTo(coordinates) <= radarRange {
                    if tile.coordinates!.distanceTo(coordinates) <= lowDetailSightRange {
                        if tile.coordinates!.distanceTo(coordinates) <= highDetailSightRange {
                            //fully rendered
                            return tile.appearance!
                        } else {
                            //only in lidar and radar range
                            if !(tile.appearance!.fillColor == .white) { //skips 'small' objects
                                return Appearance(fillColor: tile.appearance!.fillColor, symbolColor: tile.appearance!.fillColor, symbol: "rectangle")
                            }
                        }
                    } else {
                        //only in radar range
                        if !(tile.appearance!.fillColor == .white) { //skips 'small' objects
                            let mysteryObjectColor = Color(red: 0.4, green: 0.4, blue: 0.4) //color for an object only in Radar Range
                            return Appearance(fillColor: mysteryObjectColor, symbolColor: mysteryObjectColor, symbol: "rectangle")
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
                    return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle") //greyer if not in full range
                }
                let fog = Color(red: 0.8, green: 0.8, blue: 0.8)
                return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle") //greyer if only in radar range
            }
            let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
            return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle") // greyest if out of range
        } else {
            //renderer for out of bounds tiles
            if localCoordinates.distanceTo(coordinates) <= radarRange {
                if localCoordinates.distanceTo(coordinates) <= lowDetailSightRange {
                    return showBorderWarning ? Appearance(fillColor: .black, symbolColor: .red, symbol: "exclamationmark.triangle.fill") : Wall(coordinates: Coordinates(x: 0, y: 0, level: 0)).appearance!
                }
                let mysteryObject = Color(red: 0.4, green: 0.4, blue: 0.4)
                return Appearance(fillColor: mysteryObject, symbolColor: mysteryObject, symbol: "rectangle")
            }
            let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
            return Appearance(fillColor: fog, symbolColor: fog, symbol: "rectangle")
        }
    }
    
    var body: some View {
        let thisTile = game.board.objects.first(where: { $0.coordinates == localCoordinates && $0.appearance != nil })
        BasicTileView(appearance: getAppearenceAtLocation(), accessibilitySettings: accessibilitySettings)
            .contextMenu {
                if thisTile != nil {
                    if thisTile is Tank {
                        /*Button("􀎚 Print Status...") {
                         saveStatusCardsToPDF([thisTile as! Tank], doAlignmentCompensation: true, showBorderWarning: showBorderWarning)
                         }*/
                    }
                    Button("􀈑 Delete") {
                        game.board.objects.removeAll(where: {
                            $0 == thisTile})
                    }
                } else {
                    Button("􀂒 Add Wall") {
                        game.board.objects.append(Wall(coordinates: localCoordinates))
                    }
                    Button("􀑉 Add Gift") {
                        game.board.objects.append(Gift(coordinates: localCoordinates))
                    }
                    Button("􀭉 Add Placeholder") {
                        game.board.objects.append(Placeholder(coordinates: localCoordinates, uuid: nil))
                    }
                } //MARK: Make these reference coordinates correctly
            } //MARK: Make the Context Menus actually work, assuming they are not replaced with a new system
            .onTapGesture {
                if thisTile != nil {
                    game.board.objects.removeAll(where: {
                        $0 == thisTile})
                } else {
                    game.board.objects.append(Wall(coordinates: localCoordinates))
                }
                
            }
    }
}

#Preview {
    VStack {
        TriangleViewport(coordinates: Coordinates(x: 0, y: 0, level: 0, rotation: .south), viewRenderSize: 7, highDetailSightRange: 1, lowDetailSightRange: 2, radarRange: 3, showBorderWarning: true, accessibilitySettings: AccessibilitySettings())
            .frame(width: inch(4), height: inch(4))
        SquareViewport(coordinates: Coordinates(x: 0, y: 0, level: 0, rotation: .south), viewRenderSize: 4, highDetailSightRange: 1, lowDetailSightRange: 2, radarRange: 3, showBorderWarning: true, accessibilitySettings: AccessibilitySettings())
            .frame(width: inch(4), height: inch(4))
    }
    .background(.white)
}
