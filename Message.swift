//
//  Message.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation
import SwiftUI

struct Message: Codable, Hashable {
    var text: String // The text of the message. May be changed to arbitrary SwiftUI at some point.
    var sender: UUID // UUID of sender Tank
    var recipient: UUID // UUID of recipient Tank
}

struct MessageView: View {
    var message: Message?
    @ObservedObject var game: Game
    
    var body: some View {
        if message != nil {
            VStack(spacing: 0) {
                TankTacticsHexagon()
                    .stroke(Color.black, lineWidth: inch(0.005))
                HStack {
                    BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message!.sender })!.appearance, accessibilitySettings: (game.board.objects.first(where: { $0.uuid == message!.recipient })! as! Tank).playerInfo.accessibilitySettings)
                        .frame(width: inch(0.5), height: inch(0.5), alignment: .center)
                    Text(" To \((game.board.objects.first(where: { $0.uuid == message!.recipient })! as! Player).playerInfo.fullName)")
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
    
    @ObservedObject var game: Game
    
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
                        BasicTileView(appearance: game.board.objects.first(where: { $0.uuid == message!.sender })!.appearance, accessibilitySettings: (game.board.objects.first(where: { $0.uuid == message!.recipient })! as! Tank).playerInfo.accessibilitySettings)
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
    @State private var message: Message = Message(text: "", sender: UUID(), recipient: UUID())
    @ObservedObject var game: Game
    
    var body: some View {
        VStack {
            Text("Queue Message")
            TextField("Message", text: $message.text, axis: .vertical)
            HStack {
                Picker("Sender", selection: $message.sender) {
                    ForEach(game.board.tanks.compactMap({ $0.uuid })) { (senderId: UUID) in
                        HStack {
                            BasicTileView(appearance: game.board.tanks.first(where: { $0.uuid == senderId })!.appearance, accessibilitySettings: AccessibilitySettings())
                            Text(game.board.tanks.first(where: { $0.uuid == senderId })!.playerInfo.fullName)
                        }
                        .tag(senderId)
                    }
                }
                Picker("Recipient", selection: $message.recipient) {
                    ForEach(game.board.tanks.compactMap({ $0.uuid })) { (recipientId: UUID) in
                        HStack {
                            BasicTileView(appearance: game.board.tanks.first(where: { $0.uuid == recipientId })!.appearance, accessibilitySettings: AccessibilitySettings())
                            Text(game.board.tanks.first(where: { $0.uuid == recipientId })!.playerInfo.fullName)
                        }
                        .tag(recipientId)
                    }
                }
            }
            Button("Queue") {
                game.messages.append(message)
                message = Message(text: "", sender: UUID(), recipient: UUID())
            }
            .contextMenu {
                Button("Send to all players") {
                    for player in game.board.tanks {
                        game.messages.append(Message(text: message.text, sender: message.sender, recipient: player.uuid))
                    }
                    message.text = ""
                    message.sender = UUID()
                }
            }
            ScrollView(.vertical) {
                VStack {
                    ForEach(game.messages, id: \.self) { message in
                        HStack {
                            BasicTileView(appearance: game.board.tanks.first(where: { $0.uuid == message.sender })!.appearance, accessibilitySettings: AccessibilitySettings())
                                .frame(width: 30, height: 30, alignment: .center)
                            Image(systemName: "arrow.right")
                            BasicTileView(appearance: game.board.tanks.first(where: { $0.uuid == message.recipient })!.appearance, accessibilitySettings: AccessibilitySettings())
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
    
    let sender = previewCanvasGame.board.tanks.first!.uuid
    let recipient = previewCanvasGame.board.tanks.last!.uuid
    let text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas eleifend in nisl in varius. Proin vestibulum viverra mauris et faucibus. Vivamus egestas dapibus cursus. Mauris efficitur sollicitudin enim ornare euismod. Nulla viverra sit amet ipsum in euismod. Curabitur at euismod tortor. Nunc tincidunt condimentum enim quis porta. Nam blandit lorem ultrices tellus faucibus placerat. Proin sed pulvinar libero.
        """
    
    
    let message = Message(text: text, sender: sender, recipient: recipient)
    VSplitView {
        MessageView(message: message, game: previewCanvasGame)
        MessageBackView(message: message, game: previewCanvasGame)
    }
    .background(.white)
}
