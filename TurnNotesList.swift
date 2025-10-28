//
//  TurnNotesList.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 10/1/25.
//

import Foundation
import SwiftUI

struct TurnNotesList: View {
    @Environment(Game.self) private var game
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(game.notes, id: \.self) { note in
                    Text(note)
                }
            }
        }
    }
}
