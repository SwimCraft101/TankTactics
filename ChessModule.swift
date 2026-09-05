//
//  ChessModule.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/3/26.
//

import Foundation
import SwiftUI

fileprivate enum SquareColor {
    case light, dark
    
    var color: Color {
        switch self {
            case .light:
                return Color(white: 0.9)
            case .dark:
                return Color(white: 0.5)
        }
    }
    
    subscript() -> Color {
        color
    }
}

fileprivate enum PieceType {
    case pawn, knight, bishop, rook, queen, king
    
    var icon: String {
        switch self {
            case .pawn: "person"
            case .bishop: "graduationcap"
            case .knight: "dog"
            case .rook: "command.square"
            case .queen: "ladybug"
            case .king: "crown"
        }
    }
}

fileprivate enum PlayerColor {
    case black, white
    
    var color: Color {
        switch self {
            case .white:
                return .white
            case .black:
                return .black
        }
    }
    
    subscript() -> Color {
        color
    }
}

fileprivate typealias Piece = (type: PieceType, color: PlayerColor)

fileprivate typealias ChessBoard = [[Piece?]]

fileprivate extension ChessBoard {
    init(_ fen: String) {
        var boardData = fen.split(separator: " ")[0]
        boardData.replace("1", with: "0")
        boardData.replace("2", with: "00")
        boardData.replace("3", with: "000")
        boardData.replace("4", with: "0000")
        boardData.replace("5", with: "00000")
        boardData.replace("6", with: "000000")
        boardData.replace("7", with: "0000000")
        boardData.replace("8", with: "00000000")
        let rows = boardData.split(separator: "/")
        let fenBoard = rows.map { row in
            row.split(separator: "")
        }
        self = fenBoard.map { row in
            row.map { fenSquare in
                switch fenSquare {
                    case "0": return nil
                    case "p": return (type: .pawn, color: .black)
                    case "P": return (type: .pawn, color: .white)
                    case "b": return (type: .bishop, color: .black)
                    case "B": return (type: .bishop, color: .white)
                    case "n": return (type: .knight, color: .black)
                    case "N": return (type: .knight, color: .white)
                    case "r": return (type: .rook, color: .black)
                    case "R": return (type: .rook, color: .white)
                    case "q": return (type: .queen, color: .black)
                    case "Q": return (type: .queen, color: .white)
                    case "k": return (type: .king, color: .black)
                    case "K": return (type: .king, color: .white)
                    default: fatalError("FEN string was invalid or decoded improperly.")
                }
            }
        }
    }
}

fileprivate struct ChessSquare: View {
    let piece: Piece?
    let color: SquareColor
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color(color[])
                if piece != nil {
                    Image(systemName: piece!.type.icon + (piece!.color == .black ? ".fill" : ""))
                        .resizable()
                        .scaledToFit()
                        .frame(width: inch(0.35), height: inch(0.35), alignment: .center)
                        .foregroundStyle(.black)
                }
            }
        }
        .frame(width: inch(0.4375), height: inch(0.4375), alignment: .center)
    }
}

struct ChessGameView: View {
    @ObservedObject var game: Game

    var body: some View {
        let fen: String? = game.chessPuzzle?.fen
        let board: ChessBoard? = if fen != nil { ChessBoard(fen!) } else { nil }
        
        if fen == nil {
            Text("Chess Puzzle has not generated yet.")
        } else {
            VStack {
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    ForEach(0..<8) { rowIndex in
                        GridRow {
                            ForEach(0..<8) { columnIndex in
                                let piece = board![rowIndex][columnIndex]
                                ChessSquare(piece: piece, color: ((rowIndex + columnIndex) % 2 == 1) ? .dark : .light)
                            }
                        }
                    }
                }
                Text(((fen!.split(separator: " ")[1] == "w") ? "White" : "Black") + " to move.")
            }
        }
    }
}
