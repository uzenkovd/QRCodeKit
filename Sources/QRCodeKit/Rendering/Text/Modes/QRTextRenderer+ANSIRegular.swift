//
//  QRTextRenderer+ANSIRegular.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 31.10.2026.
//

extension QRTextRenderer {
    static func renderANSIRegular(
        _ grid: QRRenderGrid
    ) -> String {
        var rows: [String] = []

        for row in 0..<grid.size {
            var line = ANSITextLine()

            for column in 0..<grid.size {
                line.append(
                    moduleSpaces,
                    background: .module(grid[row, column])
                )
            }

            rows.append(line.string)
        }

        return rows.joined(separator: "\n")
    }
}

// MARK: - Rendering Support

private extension QRTextRenderer {
    /// A module is two spaces filled with its color as background,
    /// so no glyph depends on the terminal font.
    static let moduleSpaces = "  "
}
