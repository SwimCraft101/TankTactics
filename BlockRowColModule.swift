//
//  BlockRowColModule.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/15/26.
//

import Foundation
import SwiftUI

private let t = true
private let f = false

struct BlockRowColPuzzle {
    var solution: [[UInt8]]
    var infoGiven: [[Bool]]
    
    private static let basePuzzles: [BlockRowColPuzzle] = [
        BlockRowColPuzzle(solution: [
            [1, 2, 3, 4, 5, 6],
            [4, 5, 6, 1, 2, 3],
            [2, 3, 1, 5, 6, 4],
            [5, 6, 4, 2, 3, 1],
            [3, 1, 2, 6, 4, 5],
            [6, 4, 5, 3, 1, 2],
        ], infoGiven: [
            [t, f, t, f, t, f],
            [f, f, f, f, f, f],
            [t, f, t, f, t, f],
            [f, f, f, f, f, f],
            [t, f, t, f, t, f],
            [f, f, f, f, f, f],
        ])
    ]
    
    static var random: Self {
        var puzzle = basePuzzles.randomElement()!
        for _ in 0..<100 {
            switch Int.random(in: 0...3) {
                case 0: puzzle.cycleBlockRows()
                case 1: puzzle.cycleBlockColumns()
                case 2: puzzle.cycleRowsOfBlock()
                case 3: puzzle.cycleColumnsOfBlock()
                default: fatalError()
            }
        }
        return puzzle
    }
    
    private mutating func cycleBlockRows() {
        solution.insert(solution.removeLast(), at: 0)
        solution.insert(solution.removeLast(), at: 0)
        infoGiven.insert(infoGiven.removeLast(), at: 0)
        infoGiven.insert(infoGiven.removeLast(), at: 0)
    }
    
    private mutating func cycleBlockColumns() {
        for solutionRowIndex in solution.indices {
            var solutionRow = solution[solutionRowIndex]
            solutionRow.insert(solutionRow.removeLast(), at: 0)
            solutionRow.insert(solutionRow.removeLast(), at: 0)
            solutionRow.insert(solutionRow.removeLast(), at: 0)
            solution[solutionRowIndex] = solutionRow
        }
        for infoGivenRowIndex in infoGiven.indices {
            var infoGivenRow = infoGiven[infoGivenRowIndex]
            infoGivenRow.insert(infoGivenRow.removeLast(), at: 0)
            infoGivenRow.insert(infoGivenRow.removeLast(), at: 0)
            infoGivenRow.insert(infoGivenRow.removeLast(), at: 0)
            infoGiven[infoGivenRowIndex] = infoGivenRow
        }
    }
    
    private mutating func cycleRowsOfBlock() {
        solution.insert(solution.removeLast(), at: 4)
        infoGiven.insert(infoGiven.removeLast(), at: 4)
    }
    
    private mutating func cycleColumnsOfBlock() {
        for solutionRowIndex in solution.indices {
            var solutionRow = solution[solutionRowIndex]
            solutionRow.insert(solutionRow.removeLast(), at: 3)
            solution[solutionRowIndex] = solutionRow
        }
        for infoGivenRowIndex in infoGiven.indices {
            var infoGivenRow = infoGiven[infoGivenRowIndex]
            infoGivenRow.insert(infoGivenRow.removeLast(), at: 3)
            infoGiven[infoGivenRowIndex] = infoGivenRow
        }
    }
}

private typealias BlockRowColState = [[UInt8?]]

private let digitList: [UInt8] = [1, 2, 3, 4, 5, 6]

struct BlockRowColView: View {
    let puzzle: BlockRowColPuzzle
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            Rectangle()
                .foregroundStyle(.black)
                .frame(height: inch(0.05))
            Rectangle()
                .foregroundStyle(.black)
                .frame(height: inch(0.05))
            Rectangle()
                .foregroundStyle(.black)
                .frame(height: inch(0.05))
            Rectangle()
                .foregroundStyle(.black)
                .frame(height: inch(0.05))
        }
    }
    
    private struct Row: View {
        let numbers: [UInt8]
        let enables: [Bool]
        
        var body: some View {
            GridRow {
                Rectangle()
                    .foregroundStyle(.black)
                    .frame(width: inch(0.05))
                NumberCell(number: numbers[0], enable: enables[0])
                NumberCell(number: numbers[1], enable: enables[1])
                NumberCell(number: numbers[2], enable: enables[2])
                Rectangle()
                    .foregroundStyle(.black)
                    .frame(width: inch(0.05))
                NumberCell(number: numbers[3], enable: enables[3])
                NumberCell(number: numbers[4], enable: enables[4])
                NumberCell(number: numbers[5], enable: enables[5])
                Rectangle()
                    .foregroundStyle(.black)
                    .frame(width: inch(0.05))
            }
        }
    }
    
    private struct NumberCell: View {
        let number: UInt8
        let enable: Bool
        
        var body: some View {
            Group {
                if enable {
                    Image("\(number).square")
                        .resizable()
                } else {
                    Rectangle()
                        .foregroundStyle(.white)
                }
            }
                .frame(width: inch(0.5), height: inch(0.5))
        }
    }
}

#Preview {
    BlockRowColView(puzzle: .random)
}
