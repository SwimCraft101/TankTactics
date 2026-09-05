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
/// extent of `shape` at that vertical position. Shrinks the font (like
/// `.minimumScaleFactor`) if needed to fit everything, down to a floor.
///
/// Responds normally to `.font`, `.foregroundStyle`, `.frame`, and
/// `.multilineTextAlignment` since text is resolved from the current
/// environment inside the `Canvas`.
///
/// - Important: Assumes `shape` is strictly convex. This is required for
///   correctness of the edge-sampling optimizations below (see
///   `edgeRangeAtY` and `availableXRange`). A non-convex shape (a star, a
///   heart, an L-shape) may render with the same diagonal-clipping issue
///   this was built to fix, since a concave notch can create a row with
///   more than one contiguous interval, which this version doesn't detect.
struct ShapeText<S: Shape>: View {
    let text: String
    let shape: S

    /// Precision floor for binary-searching each row's left/right edges,
    /// in points. Smaller = hugs the boundary more precisely, more
    /// iterations (cost is logarithmic, so this is cheap to shrink).
    var edgePrecision: CGFloat = 0.5

    /// Like SwiftUI's `.minimumScaleFactor` — the smallest the font is
    /// allowed to shrink to while trying to fit all the text.
    var minimumScaleFactor: CGFloat = 0.3

    private let fitTolerance: CGFloat = 0.5
    private let unbounded = CGSize(width: 10_000, height: 10_000)

    @Environment(\.multilineTextAlignment) private var alignment

    var body: some View {
        Canvas { context, size in
            let path = shape.path(in: CGRect(origin: .zero, size: size))
            draw(text: text, in: context, size: size, path: path)
        }
    }

    private struct PositionedLine {
        let resolved: GraphicsContext.ResolvedText
        let x: CGFloat
        let y: CGFloat
    }

    private struct LayoutAttempt {
        let lines: [PositionedLine]
        let fits: Bool
        let scale: CGFloat
    }

    private func draw(text: String, in context: GraphicsContext, size: CGSize, path: Path) {
        guard size.width > 0, size.height > 0 else { return }
        let paragraphs = text.components(separatedBy: .newlines)
        guard !paragraphs.isEmpty else { return }

        let bounds = path.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return }

        let naturalLineHeight = max(singleLineSize(of: "Ág", context: context).height, 1)
        let naturalSpaceWidth = singleLineSize(of: " ", context: context).width

        var wordWidthCache: [String: CGFloat] = [:]
        func naturalWordWidth(_ word: String) -> CGFloat {
            if let cached = wordWidthCache[word] { return cached }
            let w = singleLineSize(of: word, context: context).width
            wordWidthCache[word] = w
            return w
        }

        // Attempts a full wrap+pack pass at a given font `scale` (1.0 =
        // natural size). Returns the positioned lines plus whether every
        // word from every paragraph was successfully placed.
        func computeLayout(scale: CGFloat) -> LayoutAttempt {
            let lineHeight = naturalLineHeight * scale
            let spaceWidth = naturalSpaceWidth * scale
            var lines: [PositionedLine] = []
            var allFit = true
            var y: CGFloat = 0

            for paragraph in paragraphs {
                let words = paragraph.split(separator: " ").map(String.init)

                if words.isEmpty {
                    // Blank line (e.g. from "\n\n") still consumes a row.
                    if y + lineHeight <= size.height {
                        y += lineHeight
                    } else {
                        allFit = false
                    }
                    continue
                }

                var wordIndex = 0

                while wordIndex < words.count && y + lineHeight <= size.height {
                    guard let (minX, maxX) = availableXRange(rowY: y, rowHeight: lineHeight, in: path, bounds: bounds),
                          maxX - minX > 1 else {
                        // No width common to the entire row's height anywhere
                        // (e.g. a triangle's converging apex) — skip it.
                        y += lineHeight
                        continue
                    }
                    let lineWidth = maxX - minX

                    var lineWords: [String] = []
                    var currentWidth: CGFloat = 0

                    while wordIndex < words.count {
                        let word = words[wordIndex]
                        let wordWidth = naturalWordWidth(word) * scale
                        let projected = currentWidth + (lineWords.isEmpty ? 0 : spaceWidth) + wordWidth

                        if projected <= lineWidth + fitTolerance {
                            lineWords.append(word)
                            currentWidth = projected
                            wordIndex += 1
                        } else {
                            break
                        }
                    }

                    if !lineWords.isEmpty {
                        let lineString = lineWords.joined(separator: " ")
                        let resolved = context.resolve(Text(lineString))
                        let naturalSize = resolved.measure(in: unbounded)
                        let scaledWidth = naturalSize.width * scale

                        let x: CGFloat
                        switch alignment {
                        case .leading:
                            x = minX
                        case .trailing:
                            x = maxX - scaledWidth
                        case .center:
                            fallthrough
                        default:
                            x = minX + (lineWidth - scaledWidth) / 2
                        }

                        lines.append(PositionedLine(resolved: resolved, x: x, y: y))
                    }
                    // If lineWords is empty here, no word fit on this row at
                    // all; wordIndex is untouched and we retry on the next.

                    y += lineHeight
                }

                if wordIndex < words.count {
                    // Ran out of vertical space with words remaining.
                    allFit = false
                }
            }

            return LayoutAttempt(lines: lines, fits: allFit, scale: scale)
        }

        // Try natural size first; only search for a smaller scale if needed.
        let naturalAttempt = computeLayout(scale: 1.0)
        var chosen = naturalAttempt

        if !naturalAttempt.fits && minimumScaleFactor < 1.0 {
            var lo = minimumScaleFactor
            var hi: CGFloat = 1.0
            var best: LayoutAttempt?

            // Binary search for the largest scale in [minimumScaleFactor, 1.0)
            // at which everything fits.
            for _ in 0..<8 {
                let mid = (lo + hi) / 2
                let attempt = computeLayout(scale: mid)
                if attempt.fits {
                    best = attempt
                    lo = mid
                } else {
                    hi = mid
                }
            }

            // Fall back to the floor scale even if it still overflows —
            // same "best effort" cutoff as before, just at a smaller size.
            chosen = best ?? computeLayout(scale: lo)
        }

        for line in chosen.lines {
            context.drawLayer { layer in
                layer.translateBy(x: line.x, y: line.y)
                layer.scaleBy(x: chosen.scale, y: chosen.scale)
                layer.draw(line.resolved, at: .zero, anchor: .topLeading)
            }
        }
    }

    /// The natural single-line size of `string`, measured against an
    /// unbounded proposal so it can never trigger internal wrapping.
    private func singleLineSize(of string: String, context: GraphicsContext) -> CGSize {
        context.resolve(Text(string)).measure(in: unbounded)
    }

    /// The horizontal range available for a line occupying the vertical
    /// span [rowY, rowY + rowHeight].
    ///
    /// For a convex shape, the left edge `x_left(y)` is a convex function of
    /// y and the right edge `x_right(y)` is concave. A convex function's max
    /// over an interval — and a concave function's min — always occurs at
    /// an endpoint, never the interior. Since we need `max(x_left)` and
    /// `min(x_right)` across the row's height, checking just the top and
    /// bottom of the row is provably sufficient — no interior sampling can
    /// ever tighten the bound further.
    private func availableXRange(rowY: CGFloat, rowHeight: CGFloat, in path: Path, bounds: CGRect) -> (CGFloat, CGFloat)? {
        // Inset slightly from the exact top/bottom to avoid boundary
        // flakiness from `Path.contains` at the seam between rows.
        let inset = rowHeight * 0.02
        let topY = rowY + inset
        let bottomY = rowY + rowHeight - inset

        guard let top = edgeRangeAtY(topY, in: path, bounds: bounds) else { return nil }
        guard let bottom = edgeRangeAtY(bottomY, in: path, bounds: bounds) else { return nil }

        let minX = max(top.0, bottom.0)
        let maxX = min(top.1, bottom.1)
        guard minX < maxX else { return nil }
        return (minX, maxX)
    }

    /// Finds the shape's [minX, maxX] at a single height `y`, using a seed
    /// point plus binary search for each edge. Valid because a convex
    /// shape's cross-section at any height is a single contiguous
    /// interval, so containment is monotonic on either side of any point
    /// already known to be inside.
    private func edgeRangeAtY(_ y: CGFloat, in path: Path, bounds: CGRect) -> (CGFloat, CGFloat)? {
        guard y >= bounds.minY, y <= bounds.maxY else { return nil }

        // Try the bounding box's horizontal center first — inside the
        // shape at most heights for a reasonably-filled convex shape.
        let centerX = bounds.midX
        var seed: CGFloat?

        if path.contains(CGPoint(x: centerX, y: y)) {
            seed = centerX
        } else {
            // Fallback: coarse scan, but only across the shape's own
            // bounding box rather than the full canvas width.
            let coarseStep = max(edgePrecision * 4, 2)
            var x = bounds.minX
            while x <= bounds.maxX {
                if path.contains(CGPoint(x: x, y: y)) {
                    seed = x
                    break
                }
                x += coarseStep
            }
        }

        guard let seedX = seed else { return nil }

        // Binary search the left edge within [bounds.minX, seedX].
        var lo = bounds.minX
        var hi = seedX
        while hi - lo > edgePrecision {
            let mid = (lo + hi) / 2
            if path.contains(CGPoint(x: mid, y: y)) {
                hi = mid
            } else {
                lo = mid
            }
        }
        let minX = hi

        // Binary search the right edge within [seedX, bounds.maxX].
        var lo2 = seedX
        var hi2 = bounds.maxX
        while hi2 - lo2 > edgePrecision {
            let mid = (lo2 + hi2) / 2
            if path.contains(CGPoint(x: mid, y: y)) {
                lo2 = mid
            } else {
                hi2 = mid
            }
        }
        let maxX = lo2

        return (minX, maxX)
    }
}


#Preview {
    ZStack {
        Color.red
        RightTriangle()
            .foregroundStyle(.white)
        ShapeText(text: """
Dolorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam convallis vitae leo et consequat. Sed rutrum lorem eget pellentesque luctus. In in dui nec nulla semper interdum pharetra vel est. Cras varius neque sit amet risus cursus facilisis. Vivamus ultrices, leo a ultricies suscipit, lectus tortor cursus risus, a iaculis felis lorem quis purus. Duis dapibus non libero et vehicula. Nullam tortor libero, bibendum ac blandit varius, tempus tincidunt sapien. Pellentesque imperdiet libero at placerat imperdiet. Vestibulum eu tortor arcu. Donec iaculis mattis porta. Nullam suscipit consectetur tellus, sed vulputate nibh rutrum aliquam. Sed ut tristique nisi.
""", shape: RightTriangle())
        .multilineTextAlignment(.leading)
        .font(.system(size: inch(0.2)))
    }
    .frame(width: inch(3.535534), height: inch(2.715679))
}
