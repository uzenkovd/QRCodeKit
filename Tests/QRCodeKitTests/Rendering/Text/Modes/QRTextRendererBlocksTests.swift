//
//  QRTextRendererBlocksTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererBlocksTests {
    // MARK: - Module Representation

    @Test
    func rendersModuleTypes() throws {
        let samples: [(module: QRModule, expected: String)] = [
            (.data(color: .light), "██"),
            (.data(color: .dark), "░░"),
            (.function(pattern: .finder, color: .light), "██"),
            (.function(pattern: .finder, color: .dark), "░░"),
            (.function(pattern: .separator, color: .light), "██"),
            (.function(pattern: .separator, color: .dark), "░░"),
            (.function(pattern: .alignment, color: .light), "██"),
            (.function(pattern: .alignment, color: .dark), "░░"),
            (.function(pattern: .timing, color: .light), "██"),
            (.function(pattern: .timing, color: .dark), "░░"),
            (.darkModule, "░░"),
            (.information(type: .format, color: .light), "██"),
            (.information(type: .format, color: .dark), "░░"),
            (.information(type: .version, color: .light), "██"),
            (.information(type: .version, color: .dark), "░░"),
            (.reserved(.format), "RR"),
            (.reserved(.version), "RR"),
            (.unset, "??")
        ]

        var matrix = QRMatrix(version: .v1)

        for (column, sample) in samples.enumerated() {
            matrix[0, column] = sample.module
        }

        let result = QRTextRenderer.renderBlocks(
            matrix,
            quietZoneWidth: 0
        )

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        let expectedFirstRow = samples
            .map { $0.expected }
            .joined()
            + String(
                repeating: "??",
                count: matrix.size - samples.count
            )

        #expect(firstRow == expectedFirstRow)
    }

    // MARK: - Output Layout

    @Test
    func preservesModulePositions() throws {
        var matrix = QRMatrix(version: .v1)
        let lastIndex = matrix.size - 1

        matrix[0, 0] = .data(color: .dark)
        matrix[0, lastIndex] = .function(
            pattern: .finder,
            color: .light
        )
        matrix[10, 7] = .reserved(.format)
        matrix[lastIndex, 0] = .information(
            type: .version,
            color: .light
        )
        matrix[lastIndex, lastIndex] = .darkModule

        let result = QRTextRenderer.renderBlocks(
            matrix,
            quietZoneWidth: 0
        )

        let rows = result.split(separator: "\n")

        try #require(rows.count == matrix.size)

        let expectedFirstRow =
            "░░"
            + String(repeating: "??", count: matrix.size - 2)
            + "██"

        let expectedMiddleRow =
            String(repeating: "??", count: 7)
            + "RR"
            + String(repeating: "??", count: matrix.size - 8)

        let expectedLastRow =
            "██"
            + String(repeating: "??", count: matrix.size - 2)
            + "░░"

        #expect(rows[0] == expectedFirstRow)
        #expect(rows[10] == expectedMiddleRow)
        #expect(rows[lastIndex] == expectedLastRow)
    }

    @Test(arguments: QRVersion.allCases)
    func rendersExactMatrixDimensions(
        version: QRVersion
    ) {
        let matrix = QRMatrix(version: version)

        let result = QRTextRenderer.renderBlocks(
            matrix,
            quietZoneWidth: 0
        )

        let rows = result.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        let expectedRow = String(
            repeating: "??",
            count: matrix.size
        )

        #expect(rows.count == matrix.size)
        #expect(rows.allSatisfy { $0 == expectedRow })
        #expect(!result.hasSuffix("\n"))
    }

    // MARK: - Quiet Zone

    @Test(arguments: [0, 1, 2, 4])
    func rendersQuietZone(
        width: Int
    ) {
        let matrix = QRMatrix(version: .v1)

        let result = QRTextRenderer.renderBlocks(
            matrix,
            quietZoneWidth: width
        )

        let rows = result.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        let padding = String(
            repeating: "██",
            count: width
        )

        let expectedQuietZoneRow = String(
            repeating: "██",
            count: matrix.size + width * 2
        )

        let expectedMatrixRow =
            padding
            + String(repeating: "??", count: matrix.size)
            + padding

        #expect(rows.count == matrix.size + width * 2)

        #expect(
            rows.prefix(width).allSatisfy {
                $0 == expectedQuietZoneRow
            }
        )

        #expect(
            rows.dropFirst(width)
                .prefix(matrix.size)
                .allSatisfy { $0 == expectedMatrixRow }
        )

        #expect(
            rows.suffix(width).allSatisfy {
                $0 == expectedQuietZoneRow
            }
        )

        #expect(!result.hasSuffix("\n"))
    }

    // MARK: - QRCode Rendering

    @Test
    func rendersQRCodeWithDefaultQuietZone() throws {
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

        let result = QRTextRenderer.render(
            qrCode,
            mode: .blocks
        )

        let expected = QRTextRenderer.renderBlocks(
            qrCode.matrix,
            quietZoneWidth: 4
        )

        let rows = result.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        let expectedSize = qrCode.size + 8

        let expectedQuietZoneRow = String(
            repeating: "██",
            count: expectedSize
        )

        #expect(result == expected)

        #expect(rows.count == expectedSize)
        #expect(rows.allSatisfy { $0.count == expectedSize * 2 })

        #expect(
            rows.prefix(4).allSatisfy {
                $0 == expectedQuietZoneRow
            }
        )

        #expect(
            rows.suffix(4).allSatisfy {
                $0 == expectedQuietZoneRow
            }
        )

        #expect(!result.contains("RR"))
        #expect(!result.contains("??"))
    }

    @Test
    func matchesVersion1BlocksReference() throws {
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

        let result = QRTextRenderer.renderBlocks(
            qrCode.matrix,
            quietZoneWidth: 0
        )

        #expect(
            result == Self.version1QMask0BlocksReferenceSnapshot
        )
    }
}

// MARK: - Reference Snapshots

private extension QRTextRendererBlocksTests {
    static let version1QMask0BlocksReferenceSnapshot = """
        ░░░░░░░░░░░░░░██░░░░████████░░░░░░░░░░░░░░
        ░░██████████░░██░░████░░████░░██████████░░
        ░░██░░░░░░██░░██░░████░░░░██░░██░░░░░░██░░
        ░░██░░░░░░██░░██░░██████████░░██░░░░░░██░░
        ░░██░░░░░░██░░██░░██░░██████░░██░░░░░░██░░
        ░░██████████░░██████░░██████░░██████████░░
        ░░░░░░░░░░░░░░██░░██░░██░░██░░░░░░░░░░░░░░
        ████████████████░░████████████████████████
        ██░░░░██░░██░░░░████████░░██░░██░░░░░░░░░░
        ██░░████████████░░░░░░░░████████░░██████░░
        ████░░░░██░░░░░░██░░░░██████░░██░░░░██████
        ██░░░░██░░░░██░░████░░░░██░░██░░██░░░░░░██
        ░░██████░░██░░██░░██░░░░░░██░░░░░░██░░██░░
        ████████████████░░░░██░░████░░██████░░██░░
        ░░░░░░░░░░░░░░██░░██░░████████░░██░░░░████
        ░░██████████░░████░░██░░░░██░░░░██░░██████
        ░░██░░░░░░██░░██░░██░░██████░░░░░░░░░░░░░░
        ░░██░░░░░░██░░████░░██░░██░░██░░██████░░██
        ░░██░░░░░░██░░██░░████░░██░░░░░░██░░████░░
        ░░██████████░░██░░██░░░░░░░░██████░░██░░░░
        ░░░░░░░░░░░░░░████████░░██░░░░░░████████░░
        """
}
