//
//  StockfishBridge.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/2/26.
//

import Foundation

actor EmbeddedStockfishEngine {
    private var bridge: StockfishBridge?
    private var continuationMap: [String: CheckedContinuation<String, Never>] = [:]

    var onBestMoveFound: ((String) -> Void)?

    func start() {
        bridge = StockfishBridge { [weak self] outputLine in
            guard let self = self else { return }
            Task {
                await self.handleEngineOutput(outputLine)
            }
        }

        // Send base setup
        bridge?.sendCommand("uci")
        
        // If loading custom NNUE network from resource bundle:
        if let nnuePath = Bundle.main.path(forResource: "nn-c157e0a5755b", ofType: "nnue") {
            bridge?.sendCommand("setoption name EvalFile value \(nnuePath)")
        }
        
        bridge?.sendCommand("isready")
    }

    func setPosition(fen: String) {
        bridge?.sendCommand("position fen \(fen)")
    }

    func setPosition(moves: [String]) {
        let moveString = moves.joined(separator: " ")
        bridge?.sendCommand("position startpos moves \(moveString)")
    }

    func calculateBestMove(depth: Int = 15) async -> String {
        return await withCheckedContinuation { continuation in
            self.continuationMap["bestmove"] = continuation
            self.bridge?.sendCommand("go depth \(depth)")
        }
    }

    private func handleEngineOutput(_ line: String) {
        // Intercept bestmove response
        if line.hasPrefix("bestmove") {
            let components = line.components(separatedBy: " ")
            if components.count > 1 {
                let move = components[1]
                onBestMoveFound?(move)
                
                if let continuation = continuationMap.removeValue(forKey: "bestmove") {
                    continuation.resume(returning: move)
                }
            }
        }
    }

    func stop() {
        bridge?.stop()
        bridge = nil
    }
}

@MainActor
class ChessGameViewModel: ObservableObject {
    @Published var currentMove: String = ""
    @Published var isSearching: Bool = false
    
    private let engine = EmbeddedStockfishEngine()

    init() {
        Task {
            await engine.start()
        }
    }

    func requestBestMoveForCurrentPosition(fen: String) {
        isSearching = true
        Task {
            await engine.setPosition(fen: fen)
            let move = await engine.calculateBestMove(depth: 18)
            self.currentMove = move
            self.isSearching = false
        }
    }
    
    func requestOkayMoveForCurrentPosition(fen: String) {
        isSearching = true
        Task {
            await engine.setPosition(fen: fen)
            let move = await engine.calculateBestMove(depth: 1)
            self.currentMove = move
            self.isSearching = false
        }
    }
}
