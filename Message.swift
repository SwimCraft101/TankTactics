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
    @State var messageOverflows: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message.sender })!.appearance, accessibilitySettings: (game.board.objects.first(where: { $0.uuid == message.recipient })! as! Tank).playerDemographics.accessibilitySettings)
                    .frame(width: inch(0.5), height: inch(0.5), alignment: .center)
                Text(" To \((game.board.objects.first(where: { $0.uuid == message.recipient })! as! Player).playerDemographics.fullName)")
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

struct MessageBackView: View {
    var message: Message
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                Text("Respond to ")
                    .font(.system(size: inch(0.25)))
                BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message.sender })!.appearance, accessibilitySettings: (game.board.objects.first(where: { $0.uuid == message.recipient })! as! Tank).playerDemographics.accessibilitySettings)
                    .frame(width: inch(0.25), height: inch(0.25), alignment: .center)
                Text(":")
                    .font(.system(size: inch(0.25)))
            }
            .frame(height: inch(0.25))
            ForEach(1...10, id: \.self) { _ in
                Spacer()
                RoundedRectangle(cornerRadius: inch(0.125))
                    .frame(height: inch(0.005), alignment: .topLeading)
            }
        }
        .frame(width: inch(3.1819805153), height: inch(2.4748737342), alignment: .topLeading)
    }
}

#Preview {
    let sender = game.board.objects.first(where: {$0 is Tank})!.uuid
    let recipient = game.board.objects.last(where: {$0 is Tank})!.uuid
    let text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas eleifend in nisl in varius. Proin vestibulum viverra mauris et faucibus. Vivamus egestas dapibus cursus. Mauris efficitur sollicitudin enim ornare euismod. Nulla viverra sit amet ipsum in euismod. Curabitur at euismod tortor. Nunc tincidunt condimentum enim quis porta. Nam blandit lorem ultrices tellus faucibus placerat. Proin sed pulvinar libero.
        """
    
    
    let message = Message(text: text, sender: sender, recipient: recipient)
    VSplitView {
        MessageView(message: message)
        MessageBackView(message: message)
    }
    .background(.white)
}
