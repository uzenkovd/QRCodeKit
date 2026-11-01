//
//  QRTextRenderer+ANSICompact.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.11.2026.
//

extension QRTextRenderer {
    static func renderANSICompact(
        _ grid: QRRenderGrid
    ) -> String {
        var rows: [String] = []

        for upperRow in stride(from: 0, to: grid.size, by: 2) {
            let lowerRow = upperRow + 1

            var line = ANSITextLine()

            for column in 0..<grid.size {
                let upperColor = grid[upperRow, column]

                // The last row of an odd-height grid has no lower half.
                let lowerColor = lowerRow < grid.size
                    ? grid[lowerRow, column]
                    : nil

                let cell = compactCell(
                    upper: upperColor,
                    lower: lowerColor
                )

                line.append(
                    cell.glyphs,
                    foreground: cell.foreground,
                    background: cell.background
                )
            }

            rows.append(line.string)
        }

        return rows.joined(separator: "\n")
    }
}

// MARK: - Rendering Support

private extension QRTextRenderer {
    typealias CompactCell = (
        glyphs: String,
        foreground: QRModuleColor?,
        background: ANSITextLine.Background
    )

    static let space = " "
    static let lowerHalfBlock = "\u{2584}" // ▄ LOWER HALF BLOCK
    static let upperHalfBlock = "\u{2580}" // ▀ UPPER HALF BLOCK

    /// Chooses how to draw a pair of modules in one character cell.
    static func compactCell(
        upper: QRModuleColor,
        lower: QRModuleColor?
    ) -> CompactCell {
        switch (upper, lower) {
        // A cell of one color is a space filled with that color,
        // so it does not depend on how the terminal draws glyphs.
        case (.light, .light):
            (space, nil, .module(.light))

        case (.dark, .dark):
            (space, nil, .module(.dark))

        // The lower half block showed the fewest gaps in the tested
        // terminals. The upper module is the background.
        case (.light, .dark):
            (lowerHalfBlock, .dark, .module(.light))

        case (.dark, .light):
            (lowerHalfBlock, .light, .module(.dark))

        // Without a lower half, light may widen the quiet zone,
        // but dark must not extend below the symbol.
        case (.light, nil):
            (space, nil, .module(.light))

        case (.dark, nil):
            (upperHalfBlock, .dark, .terminal)
        }
    }
}
