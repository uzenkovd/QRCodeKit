//
//  QRStructureRenderer+Rulers.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.11.2026.
//

extension QRStructureRenderer {
    /// Column numbers written vertically, one line per digit,
    /// with every digit above its column.
    ///
    /// Units are shown for every column. Higher digits are shown only
    /// at multiples of their place value, so the numbers stay readable.
    ///
    /// - Parameters:
    ///   - size: The number of columns.
    ///   - indent: The number of characters before the first column.
    static func columnRuler(
        size: Int,
        indent: Int
    ) -> [String] {
        let margin = String(repeating: " ", count: indent)
        var lines: [String] = []
        var placeValue = 1

        for _ in 0..<labelWidth(size: size) {
            let digits = (0..<size).map { column in
                placeValue == 1 || column >= placeValue && column % placeValue == 0
                    ? String(column / placeValue % 10)
                    : " "
            }

            lines.insert(margin + digits.joined(separator: " "), at: 0)
            placeValue *= 10
        }

        return lines.map(trimmingTrailingSpaces)
    }

    /// The row number, right-aligned to the widest number.
    static func rowNumber(
        _ row: Int,
        size: Int
    ) -> String {
        let number = String(row)
        let padding = String(
            repeating: " ",
            count: labelWidth(size: size) - number.count
        )

        return padding + number
    }

    /// The number of digits in the largest row or column number.
    static func labelWidth(
        size: Int
    ) -> Int {
        String(size - 1).count
    }
}

// MARK: - Support

private extension QRStructureRenderer {
    static func trimmingTrailingSpaces(
        _ line: String
    ) -> String {
        var line = line

        while line.last == " " {
            line.removeLast()
        }

        return line
    }
}
