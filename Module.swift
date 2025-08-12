//
//  Module.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/5/25.
//

import Foundation
import SwiftUI

struct ModuleView: View {
    let module: Module
    var body: some View {
        AnyView(module.view)
            .frame(width: inch(4), height: inch(4))
    }
}

class Module {
    var specialActions: [Action] {[]}
    private let tank: Tank
    
    var view: any View {
        Text("This is a base-class Module. Subclasses should override this property. If you're seeing this, something has gone VERY WRONG.")
            .font(.system(size: inch(0.3)))
    }
    
    init(tank: Tank) {
        self.tank = tank
    }
}

class TutorialModule: Module { //TODO: Fact check all info for changed details
    let isWeekTwo: Bool
    override var view: any View {
        if !isWeekTwo {
            switch game.gameDay {
            case .monday:
                Text("""
                    Welcome to Tank Tactics!
                    This is the Tutorial Module, a system designed to teach you how to play Tank Tactics during your first two weeks of gameplay. You will be guided through all the important information to playing Tank Tactics. Note that some information will be intentionally vauge, as some elements of the game are not publicly documented in detail to preserve the strategy of wielding knowledge tactfully.
                    The upper triangle flap is the Viewport. The Viewport shows the perspective of your Tank in the direction that it is facing. note that you cannot see the orientations of other Tanks. The Viewport always shows tiles on the board exactly as they appear. Information about what these tiles are, and how to understand the viewport, will be given later.
                    
                            Accessibility Options:
                    􀂒 􀀂 Enable High Contrast Mode
                    􀂒 􀝥 Enable Colorblind Mode
                    􀂒 􀅐 Enable Large Text Mode
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.tuesday:
                Text("""
                    There are two main currencies in Tank Tactics: Fuel (􀵞), and Metal (􀇷). Fuel is used to take direct actions on the board, whereas Metal is used for upgrading your Tank. You may withdraw Fuel and Metal in their physical form to trade freely with other people, however Tank Tactics does not take responsibility for the result of thefts and will not replace stolen Fuel and Metal Tokens. Fuel and Metal Tokens may also be found around campus. You can use Fuel and Metal Tokens by folding them into your Status Card before submitting it, however the total of Fuel and Metal inside your tank, including tokens submitted that turn, must not exceed 50 each.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.wednesday:
                Text("""
                    There are two primary actions you can take on your turn. These are: Moving your tank and Firing your weapons.
                    To move your tank, draw a right triangle over a tile in the viewport. The orientation of the triangle determines the rotation of your tank by which way the viewport would face relative to your current orientation. You should choose the orientation of your tank carefully when moving, as you cannot move or fire directly behind you. Additionally, you may draw a line indicating the exact path your tank should take. You can only move one square per turn by default, however, this can be increased by purchasing the Movement Speed upgrade.
                    To fire your weapons, draw an X over a tile in the viewport. Additionally, you may draw a line indicating the exact path your missile should take. Note that if the tank you are firing on moves before you fire, you may miss them. You can only fire one square away by default, however, this can be increased by purchasing the Weapon Range upgrade.    
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.thursday:
                VStack {
                    Text("""
                        There are many types of objects you can encounter on the board in Tank Tactics. Example images are below in order of description. A Solid tile cannot be moved through, and will have a background that is not white. A Rigid tile cannot be fired through, but bullets landing on an non-Rigid tile may be able to destroy it.
                        The first, and most important, type of object is the Tank. Tanks are both Solid and Rigid. Tanks will be composed of at least two colors, making them easy to recognize. Tanks on the board represent other players in the game. 
                        Second, Walls. Walls are both Solid and Rigid. Walls are depicted as solid black.
                        Third, Gifts. Gifts are neither Solid nor Rigid, but are destroyed if fired at directly. Gifts can contain Fuel and Metal, or, in rare cases, a Module. Gifts containing only one type of benefit will, instead of the gift icon, show the icon for their respective contents. Gifts are automatically collected when you pass through or land on them whilst moving.
                """).font(.system(size: inch(0.15)))
                    HStack(spacing: 0) {
                        let coordinates = Coordinates(x: 0, y: 0, level: 0)
                        BasicTileView(appearance: Appearance(fillColor: .red, strokeColor: .yellow, symbolColor: .black, symbol: "xmark.triangle.circle.square"))
                        BasicTileView(appearance: Appearance(fillColor: .green, strokeColor: .green, symbolColor: .red, symbol: "sos"))
                        BasicTileView(appearance: Wall(coordinates: coordinates).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 1, metalReward: 1).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 1, metalReward: 0).appearance)
                        BasicTileView(appearance: Gift(coordinates: coordinates, fuelReward: 0, metalReward: 1).appearance)
                        BasicTileView(appearance: Appearance(fillColor: .white, strokeColor: .white, symbolColor: .black, symbol: "square.on.square.dashed")) //TODO: replace with reference to Gift when gifts support Modules
                    }
                    .frame(height: inch(0.5), alignment: .bottom)
                }
                .frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.friday:
                Text("""
                            Each day of the week is given a special name and purpose in Tank Tactics. A description of each follows, with more detail being given next week. The actions for each day are taken on the lower triangle flap.:
                        􀯇 Module Monday 􀯇
                            Purchase new Modules for your Tank
                        􀇾 Treacherous Tuesday 􀇾
                            All actions become 50% cheaper.
                        􂥰 Wheel Wednesday 􂥰
                            Purchase Drivetrain Upgrades for your Tank.
                        􁽇 Thrifty Thursday 􁽇
                            Trade and sell Modules and Upgrades
                        􀾲 Firearm Friday 􀾲
                            Purchase Weapon Upgrades for your Tank
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            }
        } else {
            switch game.gameDay {
            case .monday:
                Text("""
                        Modules are a system of special actions and effects in Tank Tactics. On every Monday, every player will receive identical offers to purchase Modules for their Tank. Purchasing Modules places them in your Status Card indefinitely, however, only two modules can be equipped at a time under normal circumstances. If you have too many Modules, all of your Modules will be inoperable until you select two of them. Modules are not publicly documented in detail, but a link to a video explaining any module is available on request for players with that module.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.tuesday:
                Text("""
                        On Treacherous Tuesdays, all actions are 50% cheaper. This means that this day is ideal for mounting an attack or taking more actions than usual. Because of this rapid sequence of actions, a new system for ordering actions is availible. Read on.
                
                        Precedence is a system determining which actions are processed first. Precedence works by a blind bidding system, where whoever pays the most Fuel will be first. For example, if Tank Blue Triangle wants to fire and hit Tank Red Square, she might add precedence to her move, as Tank Red Square might try to move before she can hit him. Therefore, each player is incentivized to spend more Fuel on Precedence, but spending too much can lead to the disaster of being out of gas. If two or more players have the same precedence for an action, the order between them is determined randomly.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.wednesday:
                Text("""
                        Wheel Wednesday is the day when you can purchase upgrades for your Tank's drivetrain. There are two different upgrades you can make. Movement Efficiency, and Movement Speed. Movement Efficiency reduces the cost in fuel it takes to move. Movement Speed increases the distance you can move per turn.
                
                        Event Cards are a system of special actions in Tank Tactics. Event Cards can be purchased for a varying amount of Fuel and Metal at any time, and can have a variety of actions. Event Cards are not publicly documented in detail, but the card descriptions are clear and should not cause confusion. If you have any questions about a specific event card or Tank Tactics as a whole, talk to the Game Operator.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.thursday:
                Text("""
                        On Thrifty Thursdays, you can sell your Tank's Modules and Upgrades to receive metal and/or fuel back for them. This will be necessarily less than you purchased them for. The offers may vary somewhat over time.
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            case.friday:
                Text("""
                        On Firearm Fridays, you can purchase several upgrades for your Tank's weapons. There are three different upgrades you can normally make. Weapon Range increases the distance you can fire away from your Tank. Weapon Damage increases the amount of damage your weapon deals. Weapon Efficiency reduces the cost to fire your weapon.
                
                        You have reached the end of the Tutorial Module. It will disappear automatically before your next turn. Good luck, and enjoy Tank Tactics!
                """).font(.system(size: inch(0.15))).frame(width: inch(3.8), height: inch(3.8), alignment: .center)
            }
        }
    }
    
    
    init(tank: Tank, isWeekTwo: Bool) {
        self.isWeekTwo = isWeekTwo
        super.init(tank: tank)
    }
}

class WebsitePlugModule: Module {
    override var view: any View {
        Image("youtube") //TODO: Make QR Code of the Tank Tactics Website on Google Sites, add as image reference, reference here.
    }
}

#Preview {
    let tank = Tank(appearance: Appearance(fillColor: .blue, strokeColor: .red, symbolColor: .white, symbol: "sheild"), coordinates: Coordinates(x: 0, y: 0, level: 0), playerDemographics: PlayerDemographics(firstName: "Example", lastName: "Tank", deliveryBuilding: "Nowhere Hall", deliveryType: "Nowhere", deliveryNumber: "Nothing", virtualDelivery: nil, kills: 0))
    ZStack {
        Color.white
        ModuleView(module: TutorialModule(tank: tank, isWeekTwo: true))
    }
}
