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
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer(minLength: inch(1.25))
                }
                .rotationEffect(Angle(degrees: 90))
                .frame(width: inch(5), height: inch(4), alignment: .center)
                Spacer()
                Spacer(minLength: inch(4))
                
            }
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
                HStack(spacing: 0) {
                    Image("")
                        .frame(width: inch(4.5), height: inch(4), alignment: .center)
                    MeterView(value: tank.energy, max: 10, color: .purple, label: "energy", icon: "bolt")
                    Spacer()
                }
                HStack(spacing: 0) {
                    Spacer()
                    MeterView(value: tank.essence, max: 100, color: .cyan, label: "essence", icon: "sparkles")
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

struct DeadStatusCardBack: View {
    let tank: DeadTank
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        MeterView(value: tank.energy, max: 10, color: .purple, label: "energy", icon: "bolt")
                        Spacer()
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .center)
                    SquareViewport(coordinates: game.board.objects[tank.killedByIndex].coordinates!, viewRenderSize: max(tank.energy, 3), highDetailSightRange: tank.energy - 2, lowDetailSightRange: tank.energy - 1, radarRange: tank.energy, showBorderWarning: false) //MARK: Might crash if killed by dead person. Make coordinates reference dynamically.
                        .frame(width: inch(4), height: inch(4), alignment: .center)
                }
                .frame(width: inch(5), height: inch(4), alignment: .top)
                HStack(spacing: 0) {
                    DeadControlPanelView(tank: tank)
                        .frame(width: inch(4), height: inch(4), alignment: .topLeading)
                    HStack(spacing: 0) {
                        Spacer()
                        MeterView(value: tank.essence, max: 100, color: .cyan, label: "essence", icon: "sparkles")
                    }
                    .frame(width: inch(1), height: inch(4), alignment: .center)
                }
                .frame(width: inch(5), height: inch(4), alignment: .bottom)
            }
        }
    }
}

struct DeadControlPanelView: View {
    let tank: DeadTank
    var body: some View {
        VStack(spacing:0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if tank.essence >= 1 && tank.energy >= 1 {
                        HStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(inch(0.395 / CGFloat(max(tank.energy, 3) * 2 + 1)))
                                    .foregroundColor(.white)
                                Image(systemName: "square")
                                    .frame(width: inch(3.95 / CGFloat(max(tank.energy, 3) * 2 + 1)), height: inch(3.95 / CGFloat(max(tank.energy, 3) * 2 + 1)))
                                    .foregroundColor(.black)
                                    .font(.system(size: inch(3 / CGFloat(max(tank.energy, 3) * 2 + 1))))
                            }
                            .frame(width: inch(3.95 / CGFloat(max(tank.energy, 3) * 2 + 1)), height: inch(3.95 / CGFloat(max(tank.energy, 3) * 2 + 1)))
                            Text("Draw a 􀂒 over a tile \(tank.energy) or fewer away from your killer to place a wall there.\nCosts 1 􀋥 per square of distance and 1 􀆿")
                                .font(.system(size: inch(0.1)))
                                .italic()
                                .foregroundColor(.black)
                        }
                    }
                    if tank.essence >= 3 && tank.energy >= 2 {
                        HStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(inch(0.395 / CGFloat(tank.energy * 2 + 1)))
                                    .foregroundColor(.white)
                                Image(systemName: "plus")
                                    .frame(width: inch(3.95 / CGFloat(tank.energy * 2 + 1)), height: inch(3.95 / CGFloat(tank.energy * 2 + 1)))
                                    .foregroundColor(.black)
                                    .font(.system(size: inch(3 / CGFloat(tank.energy * 2 + 1))))
                            }
                            .frame(width: inch(3.95 / CGFloat(tank.energy * 2 + 1)), height: inch(3.95 / CGFloat(tank.energy * 2 + 1)))
                            Text("Draw a 􀅼 over a tile \(Int(tank.energy / 2)) or fewer away from your killer to place a gift there.\nCosts 2 􀋥 per square of distance and 3 􀆿")
                                .font(.system(size: inch(0.1)))
                                .italic()
                                .foregroundColor(.black)
                        }
                    }
                    if tank.energy >= 5 {
                        HStack(spacing: 0) {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(inch(0.395 / CGFloat(tank.energy * 2 + 1)))
                                    .foregroundColor(.white)
                                Image(systemName: "multiply")
                                    .frame(width: inch(3.95 / CGFloat(tank.energy * 2 + 1)), height: inch(3.95 / CGFloat(tank.energy * 2 + 1)))
                                    .foregroundColor(.black)
                                    .font(.system(size: inch(3 / CGFloat(tank.energy * 2 + 1))))
                            }
                            .frame(width: inch(3.95 / CGFloat(tank.energy * 2 + 1)), height: inch(3.95 / CGFloat(tank.energy * 2 + 1)))
                            Text("Draw a 􀅾 over a tank \(tank.energy - 4) or fewer away from your killer to deal damage to that tank. This action cannot kill tanks.\nCosts 5 􀋥.")
                                .font(.system(size: inch(0.1)))
                                .italic()
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            // MARK: UpgradeOption(name: "Burn Essence", currentValue: tank.energy, upgradeIncrement: 1, upgradeCost: 2, unit: "􀋥", icon: "bolt", costUnit: "􀆿")
            // MARK: UpgradeOption(name: "Channel Energy", currentValue: tank.essence, upgradeIncrement: 1, upgradeCost: 2, unit: "􀆿", icon: "sparkles", costUnit: "􀋥")
            Spacer()
            HStack(spacing: 0) {
                Text("You were " + tank.description())
                    .font(.system(size: inch(0.15)))
                    .foregroundColor(.black)
                    .frame(width: inch(3), height: inch(1))
                BasicTileView(appearance: game.board.objects[tank.killedByIndex].appearance)
            }
            .frame(width: inch(4), height: inch(1))
        }
    }
}
