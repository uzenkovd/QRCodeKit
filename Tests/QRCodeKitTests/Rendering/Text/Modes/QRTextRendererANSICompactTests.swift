//
//  QRTextRendererANSICompactTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererANSICompactTests {
    // MARK: - Cell Encoding

    @Test
    func rendersCellCombinations() throws {
        // Columns cycle through (light, light), (light, dark),
        // (dark, light) and (dark, dark) in the first two rows.
        let matrix = QRMatrix.filled(version: .v1) { row, column in
            switch row {
            case 0: column % 4 < 2 ? .light : .dark
            case 1: column.isMultiple(of: 2) ? .light : .dark
            default: .dark
            }
        }

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        let result = QRTextRenderer.renderANSICompact(grid)

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        // Uniform cells are spaces, mixed cells are lower half blocks,
        // and every cycle repeats the same color changes.
        let cycle =
            Self.sgr("48;5;231") + " "
            + Self.sgr("38;5;16") + "▄"
            + Self.sgr("38;5;231;48;5;16") + "▄"
            + " "

        try #require(matrix.size % 4 == 1)

        let expectedFirstRow =
            String(repeating: cycle, count: matrix.size / 4)
            + Self.sgr("48;5;231") + " "
            + Self.reset

        #expect(firstRow == expectedFirstRow)
    }

    @Test
    func fillsLightAndKeepsDarkInLastRow() throws {
        let version = QRVersion.v1
        let lastIndex = version.size - 1

        let matrix = QRMatrix.filled(version: version) { row, column in
            row == lastIndex && column.isMultiple(of: 2) ? .light : .dark
        }

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        let result = QRTextRenderer.renderANSICompact(grid)

        let lastRow = try #require(
            result.split(separator: "\n").last
        )

        // Light modules fill the whole cell, while dark ones draw only
        // the upper half over the terminal background.
        let pair =
            Self.sgr("48;5;231") + " "
            + Self.sgr("49") + "▀"

        let expectedLastRow =
            Self.sgr("48;5;231") + " "
            + Self.sgr("38;5;16;49") + "▀"
            + String(repeating: pair, count: (matrix.size - 3) / 2)
            + Self.sgr("48;5;231") + " "
            + Self.reset

        #expect(lastRow == expectedLastRow)
    }

    // MARK: - Round Trip

    @Test(arguments: [0, 1, 4])
    func reproducesGridColors(
        quietZoneWidth: Int
    ) throws {
        let qrCode = try QRCode("HELLO WORLD")

        let grid = QRRenderGrid(
            matrix: qrCode.matrix,
            quietZoneWidth: quietZoneWidth
        )

        let result = QRTextRenderer.renderANSICompact(grid)
        let decodedRows = try Self.decode(result)

        let gridColors = (0..<grid.size).map { row in
            (0..<grid.size).map { column -> QRModuleColor? in
                grid[row, column]
            }
        }

        // The extra lower half under the last row is light under
        // light modules and left to the terminal under dark ones.
        let lastIndex = grid.size - 1

        let expectedExtraRow = (0..<grid.size).map { column -> QRModuleColor? in
            grid[lastIndex, column] == .light ? .light : nil
        }

        try #require(decodedRows.count == grid.size + 1)

        #expect(Array(decodedRows.prefix(grid.size)) == gridColors)
        #expect(decodedRows[grid.size] == expectedExtraRow)
        #expect(!result.hasSuffix("\n"))
    }
}

// MARK: - Escape Sequence Support

private extension QRTextRendererANSICompactTests {
    static let reset = "\u{1B}[0m"

    /// Builds a Select Graphic Rendition sequence: `ESC [ parameters m`.
    static func sgr(
        _ parameters: String
    ) -> String {
        "\u{1B}[\(parameters)m"
    }
}

// MARK: - Decoding Support

private extension QRTextRendererANSICompactTests {
    struct InvalidOutput: Error {
        let reason: String
    }

    /// Interprets the output the way a terminal would and returns
    /// the color of every half cell, top to bottom, where `nil`
    /// stands for the terminal background.
    static func decode(
        _ rendered: String
    ) throws -> [[QRModuleColor?]] {
        var rows: [[QRModuleColor?]] = []

        for line in rendered.split(separator: "\n") {
            var upperRow: [QRModuleColor?] = []
            var lowerRow: [QRModuleColor?] = []

            var foreground: QRModuleColor?
            var background: QRModuleColor?

            var scalars = line.unicodeScalars

            while let scalar = scalars.popFirst() {
                guard scalar == "\u{1B}" else {
                    let pair = try cellHalves(
                        of: scalar,
                        foreground: foreground,
                        background: background
                    )

                    upperRow.append(pair.upper)
                    lowerRow.append(pair.lower)
                    continue
                }

                guard scalars.popFirst() == "[" else {
                    throw InvalidOutput(reason: "ESC is not followed by [")
                }

                var parameters = String()

                while let next = scalars.popFirst(), next != "m" {
                    parameters.unicodeScalars.append(next)
                }

                try applySGR(
                    parameters,
                    foreground: &foreground,
                    background: &background
                )
            }

            rows.append(upperRow)
            rows.append(lowerRow)
        }

        return rows
    }

    static func applySGR(
        _ parameters: String,
        foreground: inout QRModuleColor?,
        background: inout QRModuleColor?
    ) throws {
        let values = try parameters.split(separator: ";").map { part -> Int in
            guard let value = Int(part) else {
                throw InvalidOutput(reason: "Invalid parameter \(part)")
            }

            return value
        }

        var index = 0

        while index < values.count {
            switch values[index] {
            case 0:
                foreground = nil
                background = nil
                index += 1

            case 38:
                foreground = try paletteColor(after: index, in: values)
                index += 3

            case 48:
                background = try paletteColor(after: index, in: values)
                index += 3

            case 49:
                background = nil
                index += 1

            default:
                throw InvalidOutput(reason: "Unexpected parameter \(values[index])")
            }
        }
    }

    static func paletteColor(
        after index: Int,
        in values: [Int]
    ) throws -> QRModuleColor {
        guard index + 2 < values.count, values[index + 1] == 5 else {
            throw InvalidOutput(reason: "Expected a 256-color parameter")
        }

        switch values[index + 2] {
        case 231: return .light
        case 16: return .dark
        default: throw InvalidOutput(reason: "Unexpected color \(values[index + 2])")
        }
    }

    static func cellHalves(
        of glyph: Unicode.Scalar,
        foreground: QRModuleColor?,
        background: QRModuleColor?
    ) throws -> (upper: QRModuleColor?, lower: QRModuleColor?) {
        switch glyph {
        case " ": (background, background)
        case "\u{2584}": (background, foreground)
        case "\u{2580}": (foreground, background)
        default: throw InvalidOutput(reason: "Unexpected glyph \(glyph)")
        }
    }
}
