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
        compactLines(of: grid)
            .map { cells in
                var line = ANSITextLine()

                for cell in cells {
                    let encoded = compactCell(
                        upper: cell.upper,
                        lower: cell.lower
                    )

                    line.append(
                        encoded.glyphs,
                        foreground: encoded.foreground,
                        background: encoded.background
                    )
                }

                return line.string
            }
            .joined(separator: "\n")
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
