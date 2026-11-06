//
//  QRTextRendererTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererTests {
    // MARK: - Defaults

    @Test
    func rendersCompactPlainWithStandardQuietZoneByDefault() throws {
        let qrCode = try QRCode("HELLO WORLD")

        let result = QRTextRenderer.render(qrCode)

        let expected = QRTextRenderer.render(
            qrCode,
            layout: .compact,
            style: .plain,
            quietZoneWidth: 4
        )

        #expect(result == expected)
    }

    // MARK: - Plain Style

    @Test
    func matchesPlainRegularReference() throws {
        let qrCode = try Self.referenceQRCode()

        let result = QRTextRenderer.render(
            qrCode,
            layout: .regular,
            style: .plain,
            quietZoneWidth: 1
        )

        #expect(result == Self.plainRegularReference)
    }

    @Test
    func matchesPlainCompactReference() throws {
        let qrCode = try Self.referenceQRCode()

        let result = QRTextRenderer.render(
            qrCode,
            layout: .compact,
            style: .plain,
            quietZoneWidth: 1
        )

        #expect(result == Self.plainCompactReference)
    }

    // MARK: - ANSI Style

    @Test(arguments: [0, 1, 4])
    func reproducesGridColorsInANSIRegular(
        quietZoneWidth: Int
    ) throws {
        let qrCode = try QRCode("HELLO WORLD")

        let grid = QRRenderGrid(
            matrix: qrCode.matrix,
            quietZoneWidth: quietZoneWidth
        )

        let result = QRTextRenderer.render(
            qrCode,
            layout: .regular,
            style: .ansi,
            quietZoneWidth: quietZoneWidth
        )

        let decodedRows = try Self.decode(result)

        // Every module is two spaces filled with its color, so both
        // halves of a line show each module twice.
        let expectedRows = (0..<grid.size).flatMap { row -> [[QRModuleColor?]] in
            let colors = (0..<grid.size).flatMap { column -> [QRModuleColor?] in
                [grid[row, column], grid[row, column]]
            }

            return [colors, colors]
        }

        #expect(decodedRows == expectedRows)
        #expect(!result.hasSuffix("\n"))
    }

    @Test(arguments: [0, 1, 4])
    func reproducesGridColorsInANSICompact(
        quietZoneWidth: Int
    ) throws {
        let qrCode = try QRCode("HELLO WORLD")

        let grid = QRRenderGrid(
            matrix: qrCode.matrix,
            quietZoneWidth: quietZoneWidth
        )

        let result = QRTextRenderer.render(
            qrCode,
            layout: .compact,
            style: .ansi,
            quietZoneWidth: quietZoneWidth
        )

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

// MARK: - Fixtures

private extension QRTextRendererTests {
    /// Version 1-Q with mask 0: the code shown in the reference snapshots.
    static func referenceQRCode() throws -> QRCode {
        let options = QROptions(
            version: .v1,
            encodingMode: .alphanumeric,
            errorCorrectionLevel: .Q,
            mask: .pattern0
        )

        return try QRCode(
            "HELLO WORLD",
            options: options
        )
    }
}

// MARK: - Decoding Support

private extension QRTextRendererTests {
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

// MARK: - Reference Snapshots

private extension QRTextRendererTests {
    static let plainRegularReference = """
        ██████████████████████████████████████████████
        ██              ██    ████████              ██
        ██  ██████████  ██  ████  ████  ██████████  ██
        ██  ██      ██  ██  ████    ██  ██      ██  ██
        ██  ██      ██  ██  ██████████  ██      ██  ██
        ██  ██      ██  ██  ██  ██████  ██      ██  ██
        ██  ██████████  ██████  ██████  ██████████  ██
        ██              ██  ██  ██  ██              ██
        ██████████████████  ██████████████████████████
        ████    ██  ██    ████████  ██  ██          ██
        ████  ████████████        ████████  ██████  ██
        ██████    ██      ██    ██████  ██    ████████
        ████    ██    ██  ████    ██  ██  ██      ████
        ██  ██████  ██  ██  ██      ██      ██  ██  ██
        ██████████████████    ██  ████  ██████  ██  ██
        ██              ██  ██  ████████  ██    ██████
        ██  ██████████  ████  ██    ██    ██  ████████
        ██  ██      ██  ██  ██  ██████              ██
        ██  ██      ██  ████  ██  ██  ██  ██████  ████
        ██  ██      ██  ██  ████  ██      ██  ████  ██
        ██  ██████████  ██  ██        ██████  ██    ██
        ██              ████████  ██      ████████  ██
        ██████████████████████████████████████████████
        """

    static let plainCompactReference = """
        █▀▀▀▀▀▀▀█▀▀████▀▀▀▀▀▀▀█
        █ █▀▀▀█ █ ██ ▀█ █▀▀▀█ █
        █ █   █ █ █▀███ █   █ █
        █ ▀▀▀▀▀ █▀█ █▀█ ▀▀▀▀▀ █
        ██▀▀█▀█▀▀▄███▀█▀█▀▀▀▀▀█
        ██▄▀▀█▀▀▀▄  ▄██▀█ ▀██▄█
        █▀▄▄█ ▄▀▄▀█  ▀▄▀ ▀▄ ▄▀█
        █▀▀▀▀▀▀▀█ ▄▀▄██▄▀█▀ █▄█
        █ █▀▀▀█ █▀▄▀▄▄█  ▀ ▀▀▀█
        █ █   █ █▀▄█ █ ▀ █▀█▄▀█
        █ ▀▀▀▀▀ █▄█▄ ▄ ▀▀█▄█▄ █
        ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
        """
}
