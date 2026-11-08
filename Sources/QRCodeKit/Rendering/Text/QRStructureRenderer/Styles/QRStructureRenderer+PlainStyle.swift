//
//  QRStructureRenderer+PlainStyle.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.11.2026.
//

extension QRStructureRenderer {
    /// Draws the modules in a frame, with column numbers above it
    /// and row numbers on the left.
    static func plainGrid(
        of matrix: QRMatrix
    ) -> String {
        let size = matrix.size

        // Row numbers are followed by a space, the border and a space.
        let indent = labelWidth(size: size) + 3

        let rows = (0..<size).map { row in
            rowNumber(row, size: size)
                + " │ "
                + plainRow(modules(inRow: row, of: matrix))
                + " │"
        }

        return (columnRuler(size: size, indent: indent)
            + [plainBorder(size: size, left: "┌", right: "┐")]
            + rows
            + [plainBorder(size: size, left: "└", right: "┘")])
            .joined(separator: "\n")
    }

    static func plainRow(
        _ modules: [QRModule]
    ) -> String {
        modules
            .map { String(character(for: $0)) }
            .joined(separator: " ")
    }

    static func character(
        for module: QRModule
    ) -> Character {
        switch module {
        case .data(color: .dark): "1"
        case .data(color: .light): "0"
        case let .function(pattern, color): cased(letter(for: pattern), by: color)
        case let .information(type, color): cased(letter(for: type), by: color)
        case .darkModule: "D"
        case .reserved: "R"
        case .unset: "?"
        }
    }

    static let plainLegend = """
        Dark and light modules:
        F f  finder pattern      A a  alignment pattern
        S s  separator           T t  timing pattern
        I i  format information  V v  version information
        D    dark module         1 0  data and error correction
        """
}

// MARK: - Frame

private extension QRStructureRenderer {
    /// A horizontal line that spans the modules with a space on each side.
    static func plainBorder(
        size: Int,
        left: String,
        right: String
    ) -> String {
        String(repeating: " ", count: labelWidth(size: size) + 1)
            + left
            + String(repeating: "─", count: 2 * size + 1)
            + right
    }
}

// MARK: - Letters

private extension QRStructureRenderer {
    static func letter(
        for pattern: QRFunctionPattern
    ) -> Character {
        switch pattern {
        case .finder: "F"
        case .separator: "S"
        case .alignment: "A"
        case .timing: "T"
        }
    }

    static func letter(
        for type: QRInformationType
    ) -> Character {
        switch type {
        case .format: "I"
        case .version: "V"
        }
    }

    static func cased(
        _ letter: Character,
        by color: QRModuleColor
    ) -> Character {
        switch color {
        case .dark: letter
        case .light: Character(letter.lowercased())
        }
    }
}
