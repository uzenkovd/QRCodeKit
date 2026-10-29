//
//  QRTextRenderer+Blocks.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.10.2026.
//

extension QRTextRenderer {
    static func renderBlocks(
        _ matrix: QRMatrix,
        quietZoneWidth: Int = defaultQuietZoneWidth
    ) -> String {
        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: quietZoneWidth
        )

        var rows: [String] = []

        for row in 0..<grid.size {
            var renderedRow = String()

            for column in 0..<grid.size {
                renderedRow.append(
                    blockCharacters(for: grid[row, column])
                )
            }

            rows.append(renderedRow)
        }

        return rows.joined(separator: "\n")
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
