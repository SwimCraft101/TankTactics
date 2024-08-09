//
//  StatusCard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/9/24.
//

import SwiftUI

struct StatusCard: View {
    let tank: Tank
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    StatusCard(tank: board.objects.first as! Tank)
}
