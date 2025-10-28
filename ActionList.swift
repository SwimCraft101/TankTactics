//
//  ActionList.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 9/18/25.
//

import Foundation
import SwiftUI

struct ActionList: View {
    @Bindable private var game = Game.shared
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("Actions Queued")
                Grid {
                    ForEach(game.actions, id: \.id) { (action: TankAction) in
                        GridRow {
                            Text("\(action.precedence)")
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .font(.system(size: 15))
                                .foregroundStyle((action.precedence == 0) ? .secondary : .primary)
                            BasicTileView(appearance: action.tank.appearance!, accessibilitySettings: AccessibilitySettings())
                                .frame(width: 30, height: 30)
                            Image(systemName: action.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            if let singleDirectionAction = action as? SingleDirectionAction {
                                Image(systemName: singleDirectionAction.direction.fromPerspectiveOf(.north).arrowIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            if let multiDirectionAction = action as? MultiDirectionAction {
                                ForEach(multiDirectionAction.vector, id: \.self) { step in
                                    Image(systemName: step.fromPerspectiveOf(.north).arrowIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                }
                            }
                            if let move = action as? Move {
                                Image(systemName: move.rotation.fromPerspectiveOf(.north).arrowIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30, height: 30)
                            }
                            if let arbitraryFuelAndMetalAmountAction = action as? ArbitraryFuelAndMetalAmountAction {
                                Text("\(arbitraryFuelAndMetalAmountAction.fuelAmount)􀵞")
                                    .font(.system(size: 20))
                                Text("\(arbitraryFuelAndMetalAmountAction.metalAmount)􀇷")
                                    .font(.system(size: 20))
                            }
                        }
                        .contextMenu {
                            Button("􀈑 Unqueue Action") {
                                game.actions.removeAll(where: { $0 === action })
                            }
                        }
                    }
                }
            }
        }
    }
}
