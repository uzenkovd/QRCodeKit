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
        precondition(
            quietZoneWidth >= 0,
            "Quiet zone width must be nonnegative"
        )

        let padding = String(
            repeating: lightBlock,
            count: quietZoneWidth
        )

        let quietZoneRow = String(
            repeating: lightBlock,
            count: matrix.size + quietZoneWidth * 2
        )

        var rows: [String] = []

        for _ in 0..<quietZoneWidth {
            rows.append(quietZoneRow)
        }

        for row in 0..<matrix.size {
            var renderedRow = padding

            for column in 0..<matrix.size {
                let module = matrix[row, column]

                renderedRow.append(
                    blockCharacters(for: module)
                )
            }

            renderedRow.append(padding)
            rows.append(renderedRow)
        }

        for _ in 0..<quietZoneWidth {
            rows.append(quietZoneRow)
        }

        return rows.joined(separator: "\n")
    }
}

// MARK: - Rendering Support

private extension QRTextRenderer {
    static let darkBlock = "░░"
    static let lightBlock = "██"

    static func blockCharacters(
        for module: QRModule
    ) -> String {
        switch module {
        case .data(color: .light),
             .function(pattern: _, color: .light),
             .information(type: _, color: .light):
            return lightBlock

        case .data(color: .dark),
             .function(pattern: _, color: .dark),
             .information(type: _, color: .dark),
             .darkModule:
            return darkBlock

        case .reserved:
            return "RR"

        case .unset:
            return "??"
        }
    }
}
