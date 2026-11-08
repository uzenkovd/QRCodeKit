//
//  QRStructureRenderer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.10.2026.
//

/// Renders the structure of a QR code as text: one character per module,
/// showing which part of the symbol the module belongs to.
///
/// The output is a diagnostic view and cannot be scanned.
enum QRStructureRenderer {
    /// Returns one line per row of the symbol, with modules separated by spaces.
    ///
    /// Modules are shown as:
    /// - `0` and `1`: light and dark modules of data
    ///   and error correction codewords;
    /// - `F`, `S`, `A` and `T`: finder, separator, alignment
    ///   and timing patterns;
    /// - `D`: the dark module;
    /// - `I` and `V`: format and version information.
    static func render(
        _ qrCode: QRCode
    ) -> String {
        render(qrCode.matrix)
    }
}

// MARK: - Matrix Rendering

extension QRStructureRenderer {
    /// Renders a matrix at any stage of generation.
    ///
    /// Unfinished matrices may contain reserved modules, shown as `R`,
    /// and unset modules, shown as `?`.
    static func render(
        _ matrix: QRMatrix
    ) -> String {
        var rows: [String] = []

        for row in 0..<matrix.size {
            var renderedRow = String()

            for column in 0..<matrix.size {
                let module = matrix[row, column]

                if column > 0 {
                    renderedRow.append(" ")
                }

                renderedRow.append(
                    character(for: module)
                )
            }

            rows.append(renderedRow)
        }

        return rows.joined(separator: "\n")
    }
}

// MARK: - Module Characters

private extension QRStructureRenderer {
    static func character(
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
