//
//  Message.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation
import SwiftUI

struct Message: Codable, Hashable {
    let text: String // The text of the message. May be changed to arbitrary SwiftUI at some point.
    let sender: UUID // UUID of sender Tank
    let recipient: UUID // UUID of recipient Tank
}

struct MessageView: View {
    var message: Message?
    
    var body: some View {
        if message != nil {
            VStack(spacing: 0) {
                TankTacticsHexagon()
                    .stroke(Color.black, lineWidth: inch(0.005))
                HStack {
                    BasicTileView(appearance: Game.shared.board.objects.first(where: { $0.uuid == message!.sender })!.appearance, accessibilitySettings: (Game.shared.board.objects.first(where: { $0.uuid == message!.recipient })! as! Tank).playerInfo.accessibilitySettings)
                        .frame(width: inch(0.5), height: inch(0.5), alignment: .center)
                    Text(" To \((Game.shared.board.objects.first(where: { $0.uuid == message!.recipient })! as! Player).playerInfo.fullName)")
                        .font(.system(size: inch(0.25)))
                        .italic()
                }
                .frame(width: inch(3.535534), height: inch(0.5), alignment: .topLeading)
                HStack(spacing: 0) {
                    Spacer()
                    Text(message!.text)
                        .font(.system(size: inch(0.15)))
                        .frame(width: inch(3.535534 - 0.5), height: inch(2.715679 - 0.5), alignment: .topLeading)
                    
                }
            }
            .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
        } else {
            EmptyView()
        }
    }
}

struct MessageBackView: View {
    var message: Message?
    
    var body: some View {
        ZStack {
            TankTacticsHexagon()
                .scale(x: -1, anchor: .center)
                .stroke(Color.black, lineWidth: inch(0.005))
            VStack(spacing: 0) {
                if message != nil {
                    HStack(spacing: 0) {
                        Spacer()
                        Text("Respond to ")
                            .font(.system(size: inch(0.25)))
                        BasicTileView(appearance: Game.shared.board.objects.first(where: { $0.uuid == message!.sender })!.appearance, accessibilitySettings: (Game.shared.board.objects.first(where: { $0.uuid == message!.recipient })! as! Tank).playerInfo.accessibilitySettings)
                            .frame(width: inch(0.25), height: inch(0.25), alignment: .center)
                        Text(":")
                            .font(.system(size: inch(0.25)))
                    }
                    .frame(height: inch(0.25))
                    ForEach(1...10, id: \.self) { _ in
                        Spacer()
                        RoundedRectangle(cornerRadius: inch(0.125))
                            .frame(height: inch(0.005), alignment: .topTrailing)
                    }
                }
            }
            .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
        }
    }
}

struct MessageList: View {
    @Environment(Game.self) private var game
    
    @State private var messageText: String = ""
    @State private var messageSender: BoardObject? = nil
    @State private var messageRecipient: BoardObject? = nil
    
    var body: some View {
        VStack {
            Text("Queue Message")
            TextField("Message", text: $messageText, axis: .vertical)
            HStack {
                Picker("Sender", selection: $messageSender) {
                    ForEach(game.board.objects.filter{ $0 is Player }) { (sender: BoardObject) in
                        HStack {
                            BasicTileView(appearance: sender.appearance, accessibilitySettings: AccessibilitySettings())
                            Text((sender as! Player).playerInfo.fullName)
                        }
                        .tag(sender)
                    }
                }
                Picker("Recipient", selection: $messageRecipient) {
                    ForEach(game.board.objects.filter{ $0 is Player }) { (recipient: BoardObject) in
                        HStack {
                            BasicTileView(appearance: recipient.appearance, accessibilitySettings: AccessibilitySettings())
                            Text((recipient as! Player).playerInfo.fullName)
                        }
                        .tag(recipient)
                    }
                }
            }
            Button("Queue") {
                game.messages.append(Message(text: messageText, sender: messageSender!.uuid, recipient: messageRecipient!.uuid))
                messageText = ""
                messageSender = nil
                messageRecipient = nil
            }
            .disabled(messageRecipient == nil || messageSender == nil)
            .contextMenu {
                Button("Send to all players") {
                    for player in game.board.objects.filter({ $0 is Player }) {
                        game.messages.append(Message(text: messageText, sender: messageSender!.uuid, recipient: player.uuid))
                    }
                    messageText = ""
                    messageSender = nil
                }
                .disabled(messageSender == nil)
            }
            ScrollView(.vertical) {
                VStack {
                    ForEach(game.messages, id: \.self) { message in
                        HStack {
                            BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message.sender })!.appearance, accessibilitySettings: AccessibilitySettings())
                                .frame(width: 30, height: 30, alignment: .center)
                            Image(systemName: "arrow.right")
                            BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message.recipient })!.appearance, accessibilitySettings: AccessibilitySettings())
                                .frame(width: 30, height: 30, alignment: .center)
                            Text(message.text)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable 
    
    let sender = Game.shared.board.objects.first(where: {$0 is Tank})!.uuid
    let recipient = Game.shared.board.objects.last(where: {$0 is Tank})!.uuid
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
