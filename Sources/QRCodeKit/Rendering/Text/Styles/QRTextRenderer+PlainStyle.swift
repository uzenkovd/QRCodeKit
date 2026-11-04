//
//  QRTextRenderer+PlainStyle.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 03.11.2026.
//

extension QRTextRenderer {
    static func plainRegularLine(
        _ colors: [QRModuleColor]
    ) -> String {
        colors.map(regularCharacters(for:)).joined()
    }

    static func plainCompactLine(
        _ cells: [CompactCellColors]
    ) -> String {
        String(
            cells.map {
                compactCharacter(upper: $0.upper, lower: $0.lower)
            }
        )
    }
}

// MARK: - Regular Glyphs

private extension QRTextRenderer {
    static let lightBlock = "██"
    static let darkBlock = "░░"

    static func regularCharacters(
        for color: QRModuleColor
    ) -> String {
        switch color {
        case .light: lightBlock
        case .dark: darkBlock
        }
    }
}

// MARK: - Compact Glyphs

private extension QRTextRenderer {
    static let fullBlock: Character = "\u{2588}"      // █ FULL BLOCK
    static let upperHalfBlock: Character = "\u{2580}" // ▀ UPPER HALF BLOCK
    static let lowerHalfBlock: Character = "\u{2584}" // ▄ LOWER HALF BLOCK
    static let emptyBlock: Character = " "

    /// Glyphs draw light modules and leave dark ones blank,
    /// so the output assumes a dark background.
    /// A `nil` lower half marks the last row of an odd-height grid.
    static func compactCharacter(
        upper: QRModuleColor,
        lower: QRModuleColor?
    ) -> Character {
        switch (upper, lower) {
        case (.light, .light):
            fullBlock

        case (.light, .dark), (.light, nil):
            upperHalfBlock

        case (.dark, .light):
            lowerHalfBlock

        case (.dark, .dark), (.dark, nil):
            emptyBlock
        }
    }
}
