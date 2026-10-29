//
//  QRTextRendererCompactTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 27.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererCompactTests {
    // MARK: - Character Mapping

    @Test
    func rendersHalfBlockCombinations() throws {
        // Columns cycle through (light, light), (light, dark),
        // (dark, light) and (dark, dark) in the first two rows.
        let matrix = QRMatrix.filled(version: .v1) { row, column in
            switch row {
            case 0: column % 4 < 2 ? .light : .dark
            case 1: column.isMultiple(of: 2) ? .light : .dark
            default: .dark
            }
        }

        let result = QRTextRenderer.renderCompact(
            matrix,
            quietZoneWidth: 0
        )

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        let pattern: [Character] = ["█", "▀", "▄", " "]

        let expectedFirstRow = String(
            (0..<matrix.size).map { pattern[$0 % 4] }
        )

        #expect(firstRow == expectedFirstRow)
    }

    @Test
    func rendersLastRowWithoutLowerHalf() throws {
        let version = QRVersion.v1
        let lastIndex = version.size - 1

        let matrix = QRMatrix.filled(version: version) { row, column in
            row == lastIndex && column.isMultiple(of: 2) ? .light : .dark
        }

        let result = QRTextRenderer.renderCompact(
            matrix,
            quietZoneWidth: 0
        )

        let lastRow = try #require(
            result.split(separator: "\n").last
        )

        let expectedLastRow = String(
            (0..<matrix.size).map {
                $0.isMultiple(of: 2) ? "▀" : " "
            }
        )

        #expect(lastRow == expectedLastRow)
    }

    // MARK: - Quiet Zone

    @Test(arguments: [0, 1, 2, 3, 4])
    func rendersQuietZone(
        width: Int
    ) throws {
        let matrix = QRMatrix.filled(version: .v1) { _, _ in .dark }
        let paddedSize = matrix.size + width * 2
        let matrixRange = width..<(width + matrix.size)

        let result = QRTextRenderer.renderCompact(
            matrix,
            quietZoneWidth: width
        )

        let modules = try Self.unpackCompact(result)

        let expectedModules = (0..<paddedSize).map { row in
            (0..<paddedSize).map { column in
                !(matrixRange.contains(row) && matrixRange.contains(column))
            }
        }

        // An odd-height grid leaves one undrawn lower half.
        try #require(modules.count == paddedSize + 1)

        #expect(Array(modules.prefix(paddedSize)) == expectedModules)
        #expect(modules[paddedSize].allSatisfy { !$0 })
        #expect(!result.hasSuffix("\n"))
    }

    // MARK: - QRCode Rendering

    @Test
    func rendersQRCodeWithDefaultQuietZone() throws {
        let qrCode = try QRCode("HELLO WORLD")

        let result = QRTextRenderer.render(
            qrCode,
            mode: .compact
        )

        let expected = QRTextRenderer.renderCompact(
            qrCode.matrix,
            quietZoneWidth: 4
        )

        #expect(result == expected)
    }

    @Test
    func matchesVersion1CompactReference() throws {
        let options = QROptions(
            version: .v1,
            encodingMode: .alphanumeric,
            errorCorrectionLevel: .Q,
            mask: .pattern0
        )

        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )

        let result = QRTextRenderer.renderCompact(
            qrCode.matrix,
            quietZoneWidth: 1
        )

        #expect(result == Self.version1QMask0CompactReferenceSnapshot)
    }
}

// MARK: - Unpacking Support

private extension QRTextRendererCompactTests {
    struct UnexpectedCharacter: Error {
        let character: Character
    }

    /// Splits each character into its upper and lower halves.
    /// `true` means the half is drawn, that is, the module is light.
    static func unpackCompact(
        _ rendered: String
    ) throws -> [[Bool]] {
        var modules: [[Bool]] = []

        for row in rendered.split(separator: "\n") {
            var upperRow: [Bool] = []
            var lowerRow: [Bool] = []

            for character in row {
                let pair = try halves(of: character)

                upperRow.append(pair.upper)
                lowerRow.append(pair.lower)
            }

            modules.append(upperRow)
            modules.append(lowerRow)
        }

        return modules
    }

    static func halves(
        of character: Character
    ) throws -> (upper: Bool, lower: Bool) {
        switch character {
        case "█": (true, true)
        case "▀": (true, false)
        case "▄": (false, true)
        case " ": (false, false)
        default: throw UnexpectedCharacter(character: character)
        }
    }
}

// MARK: - Reference Snapshots

private extension QRTextRendererCompactTests {
    static let version1QMask0CompactReferenceSnapshot = """
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
