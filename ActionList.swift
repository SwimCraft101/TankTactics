//
//  ActionList.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 9/18/25.
//

import Foundation
import SwiftUI

struct ActionList: View {
    @ObservedObject var game: Game
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("Actions Queued")
                Grid {
                    #warning("Reimplement Action List")
                }
            }
        }
    }
}
