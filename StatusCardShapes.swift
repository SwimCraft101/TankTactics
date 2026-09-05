//
//  Status Card Shapes.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/18/26.
//

import Foundation
import SwiftUI

struct RightTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Draw a line to the bottom-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Draw a line to the top-left corner (forming the right angle)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        // Close the path back to the starting point
        path.closeSubpath()

        return path
    }
}

struct TankTacticsHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let rectangle: CGRect = CGRect(x: rect.minX, y: rect.minY, width: inch(3.535534), height: inch(2.715679))
        
        var path = Path()

        // Start at the top-left corner
        path.move(to: CGPoint(x: rectangle.minX, y: rectangle.minY))

        // Draw a line to the bottom-left corner, offset a little to make the corner cut.
        path.addLine(to: CGPoint(x: rectangle.minX, y: rectangle.maxY - inch(0.5)))
        path.addLine(to: CGPoint(x: rectangle.minX + inch(0.5), y: rectangle.maxY))
        
        // Draw a line to the bottom-right corner
        path.addLine(to: CGPoint(x: rectangle.maxX, y: rectangle.maxY))
        
        // Draw a line to the top-right corner, offset a little to make the corner cut.
        path.addLine(to: CGPoint(x: rectangle.maxX, y: rectangle.minY + inch(0.5)))
        path.addLine(to: CGPoint(x: rectangle.maxX - inch(0.5), y: rectangle.minY))

        // Close the path back to the starting point
        path.closeSubpath()

        return path
    }
}

/// Renders `text`, word-wrapped so each line fits within the horizontal
/// extent of `shape` at that vertical position.
///
/// Responds normally to `.font`, `.foregroundStyle`, and `.frame` since
/// text is resolved from the current environment inside the `Canvas`.
import SwiftUI

struct ShapeText<S: Shape>: View {
    let text: String
    let shape: S
    var samplingStep: CGFloat = 2

    @Environment(\.multilineTextAlignment) private var alignment

    var body: some View {
        Canvas { context, size in
            let path = shape.path(in: CGRect(origin: .zero, size: size))
            draw(text: text, in: context, size: size, path: path)
        }
    }

    private func draw(text: String, in context: GraphicsContext, size: CGSize, path: Path) {
        guard size.width > 0, size.height > 0 else { return }
        let words = text.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return }

        let probe = context.resolve(Text("Ág"))
        let lineHeight = max(probe.measure(in: size).height, 1)
        let spaceWidth = context.resolve(Text(" ")).measure(in: size).width

        var wordIndex = 0
        var y: CGFloat = 0

        while wordIndex < words.count && y + lineHeight <= size.height {
            guard let (minX, maxX) = availableXRange(atY: y + lineHeight / 2, in: path, width: size.width),
                  maxX - minX > 1 else {
                y += lineHeight
                continue
            }
            let lineWidth = maxX - minX

            var lineWords: [String] = []
            var currentWidth: CGFloat = 0

            while wordIndex < words.count {
                let word = words[wordIndex]
                let wordWidth = context.resolve(Text(word)).measure(in: size).width
                let projected = currentWidth + (lineWords.isEmpty ? 0 : spaceWidth) + wordWidth

                if projected <= lineWidth || lineWords.isEmpty {
                    lineWords.append(word)
                    currentWidth = projected
                    wordIndex += 1
                } else {
                    break
                }
            }

            let lineText = context.resolve(Text(lineWords.joined(separator: " ")))
            let lineSize = lineText.measure(in: size)

            // Use the environment's multilineTextAlignment to place this line.
            let x: CGFloat
            switch alignment {
            case .leading:
                x = minX
            case .trailing:
                x = maxX - lineSize.width
            case .center:
                fallthrough
            default:
                x = minX + (lineWidth - lineSize.width) / 2
            }

            context.draw(lineText, at: CGPoint(x: x, y: y), anchor: .topLeading)
            y += lineHeight
        }
    }

    private func availableXRange(atY y: CGFloat, in path: Path, width: CGFloat) -> (CGFloat, CGFloat)? {
        var minX: CGFloat?
        var maxX: CGFloat?
        var x: CGFloat = 0
        while x <= width {
            if path.contains(CGPoint(x: x, y: y)) {
                if minX == nil { minX = x }
                maxX = x
            }
            x += samplingStep
        }
        guard let mn = minX, let mx = maxX else { return nil }
        return (mn, mx)
    }
}
