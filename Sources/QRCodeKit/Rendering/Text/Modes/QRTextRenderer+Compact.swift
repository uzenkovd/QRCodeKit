//
//  QRTextRenderer+Compact.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 27.10.2026.
//

extension QRTextRenderer {
    static func renderCompact(
        _ matrix: QRMatrix,
        quietZoneWidth: Int = defaultQuietZoneWidth
    ) -> String {
        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: quietZoneWidth
        )

        var rows: [String] = []

        for upperRow in stride(from: 0, to: grid.size, by: 2) {
            let lowerRow = upperRow + 1

            var renderedRow = String()

            for column in 0..<grid.size {
                let upperColor = grid[upperRow, column]

                // The last row of an odd-height grid has no lower half.
                let lowerColor = lowerRow < grid.size
                    ? grid[lowerRow, column]
                    : nil

                renderedRow.append(
                    compactCharacter(
                        upper: upperColor,
                        lower: lowerColor
                    )
                )
            }

            rows.append(renderedRow)
        }

        return rows.joined(separator: "\n")
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
