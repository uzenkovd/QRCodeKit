//
//  QRTextRenderer+ANSIStyle.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 03.11.2026.
//

extension QRTextRenderer {
    static func ansiRegularLine(
        _ colors: [QRModuleColor]
    ) -> String {
        var line = ANSITextLine()

        for color in colors {
            line.append(
                moduleSpaces,
                background: .module(color)
            )
        }

        return line.string
    }

    static func ansiCompactLine(
        _ cells: [CompactCellColors]
    ) -> String {
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
}

// MARK: - Regular Glyphs

private extension QRTextRenderer {
    /// A module is two spaces filled with its color as background,
    /// so no glyph depends on the terminal font.
    static let moduleSpaces = "  "
}

// MARK: - Compact Glyphs

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
