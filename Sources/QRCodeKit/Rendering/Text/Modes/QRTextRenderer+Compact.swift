//
//  QRTextRenderer+Compact.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 27.10.2026.
//

extension QRTextRenderer {
    static func renderCompact(
        _ grid: QRRenderGrid
    ) -> String {
        compactLines(of: grid)
            .map { cells in
                String(
                    cells.map {
                        compactCharacter(upper: $0.upper, lower: $0.lower)
                    }
                )
            }
            .joined(separator: "\n")
    }
}

// MARK: - Rendering Support

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
