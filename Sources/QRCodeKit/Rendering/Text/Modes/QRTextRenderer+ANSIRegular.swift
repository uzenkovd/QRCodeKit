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
        regularLines(of: grid)
            .map { colors in
                var line = ANSITextLine()

                for color in colors {
                    line.append(
                        moduleSpaces,
                        background: .module(color)
                    )
                }

                return line.string
            }
            .joined(separator: "\n")
    }
}

// MARK: - Rendering Support

private extension QRTextRenderer {
    /// A module is two spaces filled with its color as background,
    /// so no glyph depends on the terminal font.
    static let moduleSpaces = "  "
}
