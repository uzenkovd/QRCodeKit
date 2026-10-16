//
//  QRTextRenderer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.10.2026.
//

public enum QRTextRenderer {
    public enum Mode: Sendable {
        case debug
    }

    public static func render(
        _ qrCode: QRCode,
        mode: Mode
    ) -> String {
        switch mode {
        case .debug:
            return renderDebug(qrCode.matrix)
        }
    }
}

// MARK: - Debug Rendering

extension QRTextRenderer {
    static func renderDebug(
        _ matrix: QRMatrix
    ) -> String {
        var rows: [String] = []
        rows.reserveCapacity(matrix.size)

        for row in 0..<matrix.size {
            var renderedRow = String()
            renderedRow.reserveCapacity(matrix.size)

            for column in 0..<matrix.size {
                let module = matrix[row, column]

                renderedRow.append(
                    debugCharacter(for: module)
                )
            }

            rows.append(renderedRow)
        }

        return rows.joined(separator: "\n")
    }

    static func debugCharacter(
        for module: QRModule
    ) -> Character {
        switch module {
        case .data(color: .light):
            return "0"

        case .data(color: .dark):
            return "1"

        case .function(pattern: .finder, color: _):
            return "F"

        case .function(pattern: .separator, color: _):
            return "S"

        case .function(pattern: .alignment, color: _):
            return "A"

        case .function(pattern: .timing, color: _):
            return "T"

        case .darkModule:
            return "D"

        case .information(type: .format, color: _):
            return "I"

        case .information(type: .version, color: _):
            return "V"

        case .reserved:
            return "R"

        case .unset:
            return "?"
        }
    }
}
