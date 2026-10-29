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
    // MARK: - Character Mapping

    @Test
    func rendersModuleColors() throws {
        let matrix = QRMatrix.filled(version: .v1) { _, column in
            column.isMultiple(of: 2) ? .light : .dark
        }

        let result = QRTextRenderer.renderBlocks(
            matrix,
            quietZoneWidth: 0
        )

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        let expectedFirstRow = (0..<matrix.size)
            .map { $0.isMultiple(of: 2) ? "██" : "░░" }
            .joined()

        #expect(firstRow == expectedFirstRow)
    }

    // MARK: - Quiet Zone

    @Test(arguments: [0, 1, 4])
    func rendersQuietZone(
        width: Int
    ) {
        let matrix = QRMatrix.filled(version: .v1) { _, _ in .dark }

        let result = QRTextRenderer.renderBlocks(
            matrix,
            quietZoneWidth: width
        )

        let rows = result.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        let padding = String(repeating: "██", count: width)

        let quietZoneRow = String(
            repeating: "██",
            count: matrix.size + width * 2
        )

        let matrixRow =
            padding
            + String(repeating: "░░", count: matrix.size)
            + padding

        let expectedRows =
            Array(repeating: quietZoneRow, count: width)
            + Array(repeating: matrixRow, count: matrix.size)
            + Array(repeating: quietZoneRow, count: width)

        #expect(rows.map(String.init) == expectedRows)
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
