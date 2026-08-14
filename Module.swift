//
//  Module.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/5/25.
//

import Foundation
import SwiftUI

enum ModuleCategory {
    case minigame, info, action, ethereal
}

enum Module: View, Codable, Identifiable, Equatable, Hashable {
    case tutorial, website, radar, drone, spy, conduit, storage, construction, chessPuzzle(fen: String), numberPuzzle
    
    var id: String {
        switch self {
            case .chessPuzzle(let fen):
                return "Chess Puzzle Module (\(fen))"
            default:
                return name
        }
    }
    
    var moduleCategory: ModuleCategory {
        switch self {
            case .conduit:
                return .ethereal
            case .tutorial, .website, .chessPuzzle, .numberPuzzle:
                return .minigame
            case .drone, .construction, .storage:
                return .action
            case .radar, .spy:
                return .info
        }
    }
    
    var name: String {
        {
            switch self {
                case .tutorial:
                    return "Tutorial"
                case .website:
                    return "Website"
                case .radar:
                    return "Radar"
                case .drone:
                    return "Drone"
                case .spy:
                    return "Spy"
                case .conduit:
                    return "Conduit"
                case .storage:
                    return "Storage"
                case .construction:
                    return "Construction"
                case .chessPuzzle:
                    return "Chess Puzzle"
                case .numberPuzzle:
                    return "Number Puzzle"
                    
            }
        }() + " Module"
    }
    
    var body: some View {
        Text("Hello I am a module")
    }
}
