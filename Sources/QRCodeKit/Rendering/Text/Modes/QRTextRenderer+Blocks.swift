//
//  QRTextRenderer+Blocks.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.10.2026.
//

extension QRTextRenderer {
    static func renderBlocks(
        _ grid: QRRenderGrid
    ) -> String {
        regularLines(of: grid)
            .map { colors in
                colors.map(blockCharacters(for:)).joined()
            }
            .joined(separator: "\n")
    }
}

// MARK: - Rendering Support

private extension QRTextRenderer {
    static let lightBlock = "██"
    static let darkBlock = "░░"

    static func blockCharacters(
        for color: QRModuleColor
    ) -> String {
        switch color {
        case .light: lightBlock
        case .dark: darkBlock
        }
    }
}
