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

enum Module: Codable, Identifiable, Equatable, Hashable {
    case tutorial, website, radar, drone, spy, conduit, storage, construction, chessPuzzle, numberPuzzle
    
    var id: String {
        switch self {
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
}

struct ModuleView: View {
    @ObservedObject var game: Game
    let module: Module
    
    var body: some View {
        switch module {
            case .chessPuzzle: ChessGameView(game: game)
            default: fatalError("The requested Module View type has not been implemented.")
        }
    }
}

extension Tank {
    private var numberOfModulesByCategory: [ModuleCategory: Int] {
        var result: [ModuleCategory: Int] = [:]
        for moduleCategory in [ModuleCategory.ethereal, ModuleCategory.minigame, ModuleCategory.action, ModuleCategory.info] {
            result[moduleCategory] = modules.count(where: { $0.moduleCategory == moduleCategory })
        }
        return result
    }
    
    var hasTooManyModules: Bool {
        let numberOfConduits = modules.count(where: { $0 == .conduit })
        let numberOfModulesAllowed = 2 + numberOfConduits
        let numberOfMinigameModules = numberOfModulesByCategory[.minigame] ?? 0
        let numberOfNonMinigameModulePairs = max(numberOfModulesByCategory[.action] ?? 0, numberOfModulesByCategory[.info] ?? 0)
        let numberOfModuleSlotsUsed = numberOfNonMinigameModulePairs + numberOfMinigameModules
        return numberOfModuleSlotsUsed > numberOfModulesAllowed
    }
}
