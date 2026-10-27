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
        precondition(
            quietZoneWidth >= 0,
            "Quiet zone width must be nonnegative"
        )

        let paddedSize = matrix.size + quietZoneWidth * 2
        let matrixRange = 0..<matrix.size

        func color(
            atRow paddedRow: Int,
            column paddedColumn: Int
        ) -> QRModuleColor {
            let row = paddedRow - quietZoneWidth
            let column = paddedColumn - quietZoneWidth

            guard
                matrixRange.contains(row),
                matrixRange.contains(column)
            else {
                return .light
            }

            return moduleColor(for: matrix[row, column])
        }

        var rows: [String] = []

        for upperRow in stride(from: 0, to: paddedSize, by: 2) {
            let lowerRow = upperRow + 1

            var renderedRow = String()

            for column in 0..<paddedSize {
                let upperColor = color(atRow: upperRow, column: column)

                // The last row of an odd-height symbol has no lower half
                let lowerColor = lowerRow < paddedSize
                    ? color(atRow: lowerRow, column: column)
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

// MARK: - Module Resolution

private extension QRTextRenderer {
    static func moduleColor(
        for module: QRModule
    ) -> QRModuleColor {
        switch module {
        case .data(color: .light),
             .function(pattern: _, color: .light),
             .information(type: _, color: .light):
            return .light

        case .data(color: .dark),
             .function(pattern: _, color: .dark),
             .information(type: _, color: .dark),
             .darkModule:
            return .dark

        case .reserved, .unset:
            preconditionFailure(
                "Compact rendering requires a finalized matrix"
            )
        }
    }
}

// MARK: - Rendering Support

private extension QRTextRenderer {
    static let fullBlock: Character = "\u{2588}"      // █ FULL BLOCK
    static let upperHalfBlock: Character = "\u{2580}" // ▀ UPPER HALF BLOCK
    static let lowerHalfBlock: Character = "\u{2584}" // ▄ LOWER HALF BLOCK
    static let emptyBlock: Character = " "

    /// Light halves are drawn, dark and missing halves are left blank.
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
