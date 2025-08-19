//
//  Message.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation
import SwiftUI

struct Message: Codable {
    let text: String // The text of the message. May be changed to arbitrary SwiftUI at some point.
    let sender: UUID // UUID of sender Tank
    let recipient: UUID // UUID of recipient Tank
}

struct MessageView: View {
    var message: Message
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message.sender })!.appearance)
                    .frame(width: inch(0.5), height: inch(0.5), alignment: .center)
                Text("To \((game.board.objects.first(where: { $0.uuid == message.recipient })! as! Player).playerDemographics.fullName)")
                    .font(.system(size: inch(0.25)))
                    .italic()
            }
                .frame(width: inch(3.1819805153), height: inch(0.5), alignment: .leading)
            HStack(spacing: 0) {
                Spacer()
                Text(message.text)
                    .font(.system(size: inch(0.15)))
                    .frame(width: inch(2.6819805153), height: inch(1.9748737342), alignment: .topLeading)
                
            }
        }
        .frame(width: inch(3.1819805153), height: inch(2.4748737342), alignment: .bottomTrailing)
    }
}

#Preview {
    let sender = game.board.objects.first(where: {$0 is Tank})!.uuid
    let recipient = game.board.objects.last(where: {$0 is Tank})!.uuid
    
    let message = Message(text: "Hello, World!", sender: sender, recipient: recipient)
    MessageView(message: message)
}
