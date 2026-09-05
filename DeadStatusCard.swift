//
//  DeadStatusCard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 11/30/24.
//
import SwiftUI
import Foundation

struct DeadStatusCardFront: View {
    let tank: DeadTank
    var body: some View {
        ZStack {
                PanelToCutOff()
                    .frame(width: inch(4), height: inch(4), alignment: .bottomLeading)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: inch(5), height: inch(8), alignment: .topTrailing)
                PanelToCutOff()
                    .frame(width: inch(4), height: inch(4), alignment: .topTrailing)
                    .rotationEffect(Angle(degrees: 90))
                    .frame(width: inch(5), height: inch(8), alignment: .bottomLeading)
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
                HStack(spacing: 0) {
                    energyMeter(tank)
                }
                .frame(width: inch(5), height: inch(4), alignment: .leading)
                HStack(spacing: 0) {
                    essenceMeter(tank)
                }
                .frame(width: inch(5), height: inch(4), alignment: .trailing)
                
            }
            Text("""
                """) //renders on back of card
                .font(.system(size: inch(0.15)))
                .italic()
                .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                .rotationEffect(Angle(degrees: -45))
            
        }
    }
}

struct DeadStatusCardBack: View {
    let tank: DeadTank
    var body: some View {
        #warning("Revamp Dead Status Cards")
        /*ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ZStack {
                        TriangleViewport(coordinates: tank.killer?.coordinates ?? (tank.killer as? DeadTank)?.killer?.coordinates ?? Coordinates(x: 0, y: 0), viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, accessibilitySettings: tank.playerInfo.accessibilitySettings, selectedObject: selectedObjectBindingDefault)
                            .frame(width: inch(4), height: inch(4), alignment: .leading)
                        PanelToCutOff()
                            .frame(width: inch(4), height: inch(4))
                            .rotationEffect(Angle(degrees: 180))
                    }
                    .frame(width: inch(4), height: inch(4), alignment: .leading)
                    Spacer()
                    energyMeter(tank)
                        .frame(width: inch(0.5), alignment: .trailing)
                }
                .frame(width: inch(5), height: inch(4), alignment: .trailing)
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        essenceMeter(tank)
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .leading)
                    ZStack {
                        DeadControlPanelView(tank: tank)
                        PanelToCutOff()
                    }
                    .frame(width: inch(4), height: inch(4), alignment: .topTrailing) 
                }
                .frame(width: inch(5), height: inch(4), alignment: .bottomTrailing)
            }
        }
        .frame(width: inch(5), height: inch(8), alignment: .center)*/
    }
}

func energyMeter(_ tank: DeadTank) -> MeterView {
    return MeterView(value: tank.energy, max: 10, color: .cyan.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Energy", icon: "bolt")
}

func essenceMeter(_ tank: DeadTank) -> MeterView {
    return MeterView(value: tank.essence, max: 50, color: .purple.opacity(tank.playerInfo.accessibilitySettings.highContrast || tank.playerInfo.accessibilitySettings.colorblind ? 0.5 : 1), label: "Essence", icon: "sparkles")
}
/*
struct DeadControlPanelView: View {
    let tank: DeadTank
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if tank.essence >= 1 && tank.energy >= 1 {
                Text("  Draw a 􀂒 over a tile \(tank.energy) or fewer away from your killer to place a wall there.\nCosts 1 􀋥 per square of distance and 1 􀆿")
                    .font(.system(size: inch(0.12)))
                    .italic()
                    .foregroundColor(.black)
                    .frame(width: inch(3.5), height: inch(0.5), alignment: .topLeading)
            }
            if tank.essence >= 3 && tank.energy >= 2 {
                Text("  Draw a 􀅼 over a tile \(Int(tank.energy / 2)) or fewer away from your killer to place a gift there.\nCosts 2 􀋥 per square of distance and 3 􀆿")
                    .font(.system(size: inch(0.12)))
                    .italic()
                    .foregroundColor(.black)
                    .frame(width: inch(3), height: inch(0.5), alignment: .topLeading)
            }
            if tank.energy >= 5 {
                Text("  Draw a 􀅾 over a tank \(tank.energy - 4) or fewer away from your killer to deal damage to that tank. This action cannot kill tanks.\nCosts 5 􀋥.")
                    .font(.system(size: inch(0.12)))
                    .italic()
                    .foregroundColor(.black)
                    .frame(width: inch(2.3), height: inch(0.7), alignment: .topLeading)
            }
            Text("You were " + tank.description())
                .font(.system(size: inch(0.08)))
                .foregroundColor(.black)
                .frame(width: inch(1.3), height: inch(1), alignment: .topLeading)
            Spacer()
            HStack(spacing: 0) {
                BasicTileView(appearance: ((tank.killer as? DeadTank)?.killer as? DeadTank)?.killer?.appearance ?? Appearance(fillColor: .white, symbol: ""), accessibilitySettings: tank.playerInfo.accessibilitySettings)
                    .frame(width: inch(0.5), height: inch(0.5), alignment: .leading)
                BasicTileView(appearance: (tank.killer as? DeadTank)?.killer?.appearance ?? Appearance(fillColor: .white, symbol: ""), accessibilitySettings: tank.playerInfo.accessibilitySettings)
                    .frame(width: inch(0.5), height: inch(0.5), alignment: .leading)
            }
            BasicTileView(appearance: tank.killer?.appearance ?? Appearance(fillColor: .clear, symbol: ""), accessibilitySettings: tank.playerInfo.accessibilitySettings)
                .frame(height: inch(0.5))
            Image("").frame(height: inch(0.5))
        }
        .frame(width: inch(4), height: inch(4), alignment: .topLeading)
    }
}

struct DeadVirtualStatusCard: View {
    let tank: DeadTank
    
    private var messagesReceived: [Message] {
        return Game.shared.messages.filter { $0.recipient == tank.uuid }
    }
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                HStack(spacing: 0) {
                    essenceMeter(tank)
                    energyMeter(tank)
                }
                ZStack {
                    DeadControlPanelView(tank: tank)
                    TriangleViewport(coordinates: tank.killer?.coordinates ?? (tank.killer as? DeadTank)?.killer?.coordinates ?? Coordinates(x: 0, y: 0), viewRenderSize: 7, highDetailSightRange: 1000, lowDetailSightRange: 1000, radarRange: 1000, accessibilitySettings: tank.playerInfo.accessibilitySettings, selectedObject: selectedObjectBindingDefault)
                }
                .frame(width: inch(4), height: inch(4))
            }
        }
    }
}
*/
#Preview {
    DeadStatusCardBack(tank: DeadTank(appearance: Appearance(fillColor: .red, symbol: "rainbow"), killedById: previewCanvasGame.board.tanks.first!.uuid, playerInfo: PlayerInfo(firstName: "first", lastName: "last", deliveryBuilding: "build", deliveryType: "locker", deliveryNumber: "67", virtualDelivery: nil, accessibilitySettings: AccessibilitySettings(), kills: 1, doVirtualDelivery: false), essence: 23, energy: 5, uuid: UUID()))
}
