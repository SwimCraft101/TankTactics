//
//  StockfishBridge.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/2/26.
//

import Foundation


typealias ChessPuzzle = (fen: String, solution: String)

actor EmbeddedStockfishEngine {
    private var bridge: StockfishBridge?
    private var continuationMap: [String: CheckedContinuation<String, Never>] = [:]

    private var multiPVMoves: [Int: (String, Int)] = [:]
    private var topMovesContinuation: CheckedContinuation<[(String, Int)], Never>?

    var onBestMoveFound: ((String) -> Void)?

    func start() {
        bridge = StockfishBridge { [weak self] outputLine in
            guard let self = self else { return }
            NSLog("STOCKFISH: %@", outputLine)
            Task {
                await self.handleEngineOutput(outputLine)
            }
        }

        bridge?.sendCommand("uci")

        if let bigNetPath = Bundle.main.path(forResource: "nn-c288c895ea92", ofType: "nnue") {
            bridge?.sendCommand("setoption name EvalFile value \(bigNetPath)")
        } else {
            NSLog("Big NNUE file NOT FOUND in bundle")
        }

        if let smallNetPath = Bundle.main.path(forResource: "nn-37f18f62d772", ofType: "nnue") {
            bridge?.sendCommand("setoption name EvalFileSmall value \(smallNetPath)")
        } else {
            NSLog("Small NNUE file NOT FOUND in bundle")
        }
        
        bridge?.sendCommand("setoption name Threads value 4")
        
        bridge?.sendCommand("isready")
    }

    func setPosition(fen: String) {
        bridge?.sendCommand("position fen \(fen)")
    }

    func setPosition(moves: [String]) {
        let moveString = moves.joined(separator: " ")
        bridge?.sendCommand("position startpos moves \(moveString)")
    }

    func calculateBestMove(depth: Int = 16) async -> String {
        bridge?.sendCommand("setoption name MultiPV value 1")
        return await withCheckedContinuation { continuation in
            self.continuationMap["bestmove"] = continuation
            self.bridge?.sendCommand("go depth \(depth)")
        }
    }

    /// Returns the top two candidate moves with their evaluations in centipawns.
    /// Forced mates are represented as Int.max (mating) or Int.min (being mated).
    /// Note: MultiPV is already set to 2 in start(), so no toggling needed here.
    func calculateTopMoves(depth: Int = 16, numberOfMoves: Int = 2) async -> [(String, Int)] {
        bridge?.sendCommand("setoption name MultiPV value \(numberOfMoves)")
        multiPVMoves = [:]

        return await withCheckedContinuation { continuation in
            self.topMovesContinuation = continuation
            self.bridge?.sendCommand("go depth \(depth)")
        }
    }

    func generatePuzzle() async -> ChessPuzzle {
        let startingFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

        mainLoop: while true {
            var fen = startingFEN
            let targetMoveCount = Int.random(in: 16...76)

            for _ in 0..<targetMoveCount {
                setPosition(fen: fen)

                let move = await calculateTopMoves(depth: 8, numberOfMoves: 8).randomElement()?.0 ?? "(none)"

                if move.isEmpty || move == "(none)" {
                    continue mainLoop
                }

                makeMove(move, on: &fen)
                
                var topMoves = await calculateTopMoves(depth: 8)
                if topMoves.count != 2 { continue }
                topMoves.sort(by: { $0.1 > $1.1 })
                if topMoves[0].1 < 0 { continue }
                if topMoves[1].1 > 0 { continue }
                
                topMoves = await calculateTopMoves(depth: 12)
                if topMoves.count != 2 { continue }
                topMoves.sort(by: { $0.1 > $1.1 })
                if topMoves[0].1 < 100 { continue }
                if topMoves[1].1 > 0 { continue }
                return (fen, topMoves[0].0)
            }
        }
    }

    private func handleEngineOutput(_ line: String) {
        if line.hasPrefix("info") && line.contains(" multipv ") {
            parseMultiPVLine(line)
        }

        if line.hasPrefix("bestmove") {
            let components = line.components(separatedBy: " ")
            if components.count > 1 {
                let move = components[1]
                onBestMoveFound?(move)

                if let continuation = continuationMap.removeValue(forKey: "bestmove") {
                    continuation.resume(returning: move)
                }
            }

            if let topContinuation = topMovesContinuation {
                let sorted = multiPVMoves.sorted { $0.key < $1.key }.map { $0.value }
                topContinuation.resume(returning: sorted)
                topMovesContinuation = nil
            }
        }
    }

    private func parseMultiPVLine(_ line: String) {
        let tokens = line.split(separator: " ").map(String.init)

        guard let pvIdx = tokens.firstIndex(of: "multipv"), pvIdx + 1 < tokens.count,
              let multipvIndex = Int(tokens[pvIdx + 1]) else { return }

        guard let scoreIdx = tokens.firstIndex(of: "score"), scoreIdx + 2 < tokens.count else { return }
        let scoreType = tokens[scoreIdx + 1]        // "cp" or "mate"
        guard let scoreValue = Int(tokens[scoreIdx + 2]) else { return }

        let evaluation: Int
        if scoreType == "mate" {
            evaluation = scoreValue >= 0 ? Int.max : Int.min
        } else {
            evaluation = scoreValue
        }

        guard let moveIdx = tokens.firstIndex(of: "pv"), moveIdx + 1 < tokens.count else { return }
        let move = tokens[moveIdx + 1]

        multiPVMoves[multipvIndex] = (move, evaluation)
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

    static let shared = ChessGameViewModel()   // one engine for the whole app

    private let engine = EmbeddedStockfishEngine()
    private var started = false

    private init() {
        Task { await engine.start(); started = true }
    }

    func bestMove(for fen: String, depth: Int = 18) async -> String {
        await engine.setPosition(fen: fen)
        return await engine.calculateBestMove(depth: depth)
    }
    
    func puzzle() async -> ChessPuzzle {
        return await engine.generatePuzzle()
    }
}

fileprivate func makeMove(_ currentMove: String, on fen: inout String) {
    let components = fen.split(separator: " ").map(String.init)
    guard components.count == 6, currentMove.count >= 4 else { return }

    let boardStr = components[0]
    var activeColor = components[1]
    var castling = components[2]
    let epSquare = components[3]
    var halfmove = Int(components[4]) ?? 0
    var fullmove = Int(components[5]) ?? 1

    let chars = Array(currentMove)
    let fromCol = Int(chars[0].asciiValue! - Character("a").asciiValue!)
    let fromRank = Int(String(chars[1]))!
    let toCol = Int(chars[2].asciiValue! - Character("a").asciiValue!)
    let toRank = Int(String(chars[3]))!

    let fromRow = 8 - fromRank
    let toRow = 8 - toRank
    let promotion: Character? = chars.count > 4 ? chars[4] : nil

    // Parse FEN board into an 8x8 grid (row 0 = rank 8, row 7 = rank 1)
    var grid: [[Character?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    let ranks = boardStr.split(separator: "/")
    for (r, rankStr) in ranks.enumerated() {
        var c = 0
        for char in rankStr {
            if let digit = char.wholeNumberValue {
                c += digit
            } else {
                grid[r][c] = char
                c += 1
            }
        }
    }

    guard let piece = grid[fromRow][fromCol] else { return }
    let isWhite = activeColor == "w"
    let isPawn = piece == "P" || piece == "p"
    let isKing = piece == "K" || piece == "k"
    let targetPiece = grid[toRow][toCol]
    var isCapture = targetPiece != nil

    // Handle En Passant capture
    if isPawn && epSquare != "-" {
        let epCol = Int(Array(epSquare)[0].asciiValue! - Character("a").asciiValue!)
        let epRank = Int(String(Array(epSquare)[1]))!
        let epRow = 8 - epRank

        if toRow == epRow && toCol == epCol {
            isCapture = true
            let capturedPawnRow = isWhite ? toRow + 1 : toRow - 1
            grid[capturedPawnRow][toCol] = nil
        }
    }

    // Handle Castling rook movement
    if isKing && abs(toCol - fromCol) == 2 {
        if toCol == 6 { // Kingside
            let rook = grid[fromRow][7]
            grid[fromRow][7] = nil
            grid[fromRow][5] = rook
        } else if toCol == 2 { // Queenside
            let rook = grid[fromRow][0]
            grid[fromRow][0] = nil
            grid[fromRow][3] = rook
        }
    }

    // Move piece and apply promotion if specified
    grid[fromRow][fromCol] = nil
    if let promo = promotion {
        let promoStr = String(promo)
        grid[toRow][toCol] = isWhite ? Character(promoStr.uppercased()) : Character(promoStr.lowercased())
    } else {
        grid[toRow][toCol] = piece
    }

    // Determine new En Passant square for two-square pawn advances
    var nextEpSquare = "-"
    if isPawn && abs(toRow - fromRow) == 2 {
        let epRowIdx = (fromRow + toRow) / 2
        let epRankVal = 8 - epRowIdx
        let epFileChar = Character(UnicodeScalar(Character("a").asciiValue! + UInt8(fromCol)))
        nextEpSquare = "\(epFileChar)\(epRankVal)"
    }

    // Update castling availability
    if piece == "K" {
        castling = castling.replacingOccurrences(of: "K", with: "").replacingOccurrences(of: "Q", with: "")
    } else if piece == "k" {
        castling = castling.replacingOccurrences(of: "k", with: "").replacingOccurrences(of: "q", with: "")
    }

    func updateRookRights(row: Int, col: Int) {
        if row == 7 && col == 7 { castling = castling.replacingOccurrences(of: "K", with: "") }
        if row == 7 && col == 0 { castling = castling.replacingOccurrences(of: "Q", with: "") }
        if row == 0 && col == 7 { castling = castling.replacingOccurrences(of: "k", with: "") }
        if row == 0 && col == 0 { castling = castling.replacingOccurrences(of: "q", with: "") }
    }

    updateRookRights(row: fromRow, col: fromCol)
    updateRookRights(row: toRow, col: toCol)

    if castling.isEmpty { castling = "-" }

    // Update clocks and turn counter
    halfmove = (isPawn || isCapture) ? 0 : halfmove + 1
    if !isWhite { fullmove += 1 }
    activeColor = isWhite ? "b" : "w"

    // Rebuild board position string
    var boardRanks: [String] = []
    for r in 0..<8 {
        var rankStr = ""
        var emptyCount = 0
        for c in 0..<8 {
            if let p = grid[r][c] {
                if emptyCount > 0 {
                    rankStr += "\(emptyCount)"
                    emptyCount = 0
                }
                rankStr.append(p)
            } else {
                emptyCount += 1
            }
        }
        if emptyCount > 0 { rankStr += "\(emptyCount)" }
        boardRanks.append(rankStr)
    }

    fen = "\(boardRanks.joined(separator: "/")) \(activeColor) \(castling) \(nextEpSquare) \(halfmove) \(fullmove)"
}
