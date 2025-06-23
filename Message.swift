//
//  Message.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 6/20/25.
//

import Foundation

struct Message: Codable {
    let text: String // The text of the message. May be changed to arbitrary SwiftUI at some point.
    let sender: UUID // UUID of sender Tank
    let recipient: UUID // UUID of recipient Tank
}
