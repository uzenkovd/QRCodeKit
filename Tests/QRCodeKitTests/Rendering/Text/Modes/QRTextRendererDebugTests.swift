//
//  QRTextRendererDebugTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererDebugTests {
    // MARK: - Module Representation

    @Test
    func rendersModuleTypes() throws {
        var matrix = QRMatrix(version: .v1)

        let modules: [QRModule] = [
            .data(color: .light),
            .data(color: .dark),
            .function(pattern: .finder, color: .dark),
            .function(pattern: .separator, color: .light),
            .function(pattern: .alignment, color: .dark),
            .function(pattern: .timing, color: .light),
            .darkModule,
            .information(type: .format, color: .dark),
            .information(type: .version, color: .light),
            .reserved(.format),
            .reserved(.version),
            .unset
        ]

        for (column, module) in modules.enumerated() {
            matrix[0, column] = module
        }

        let result = QRTextRenderer.render(matrix, mode: .debug)

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        #expect(firstRow == "0 1 F S A T D I V R R ? ? ? ? ? ? ? ? ? ?")
    }

    @Test
    func ignoresStructuralModuleColors() throws {
        var matrix = QRMatrix(version: .v1)

        let modules: [QRModule] = [
            .function(pattern: .finder, color: .light),
            .function(pattern: .finder, color: .dark),
            .function(pattern: .separator, color: .light),
            .function(pattern: .separator, color: .dark),
            .function(pattern: .alignment, color: .light),
            .function(pattern: .alignment, color: .dark),
            .function(pattern: .timing, color: .light),
            .function(pattern: .timing, color: .dark),
            .information(type: .format, color: .light),
            .information(type: .format, color: .dark),
            .information(type: .version, color: .light),
            .information(type: .version, color: .dark)
        ]

        for (column, module) in modules.enumerated() {
            matrix[0, column] = module
        }

        let result = QRTextRenderer.render(matrix, mode: .debug)

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        #expect(firstRow == "F F S S A A T T I I V V ? ? ? ? ? ? ? ? ?")
    }

    // MARK: - Output Layout

    @Test
    func preservesModulePositions() throws {
        var matrix = QRMatrix(version: .v1)
        let lastIndex = matrix.size - 1

        matrix[0, 0] = .data(color: .dark)
        matrix[0, lastIndex] = .function(
            pattern: .finder,
            color: .dark
        )
        matrix[10, 7] = .information(
            type: .format,
            color: .light
        )
        matrix[lastIndex, 0] = .reserved(.version)
        matrix[lastIndex, lastIndex] = .darkModule

        let result = QRTextRenderer.render(matrix, mode: .debug)

        let rows = result
            .split(separator: "\n")
            .map { $0.split(separator: " ") }

        try #require(rows.count == matrix.size)
        try #require(rows.allSatisfy { $0.count == matrix.size })

        #expect(rows[0][0] == "1")
        #expect(rows[0][lastIndex] == "F")
        #expect(rows[10][7] == "I")
        #expect(rows[lastIndex][0] == "R")
        #expect(rows[lastIndex][lastIndex] == "D")
    }

    @Test(arguments: QRVersion.allCases)
    func rendersExactMatrixDimensions(
        version: QRVersion
    ) {
        let matrix = QRMatrix(version: version)

        let result = QRTextRenderer.render(matrix, mode: .debug)

        let rows = result.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        let expectedRow = Array(
            repeating: "?",
            count: matrix.size
        ).joined(separator: " ")

        #expect(rows.count == matrix.size)
        #expect(rows.allSatisfy { $0 == expectedRow })
        #expect(!result.hasSuffix("\n"))
    }

    // MARK: - QRCode Rendering

    @Test
    func matchesVersion1DebugReference() throws {
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
            mode: .debug
        )

        #expect(result == Self.version1QMask0DebugReferenceSnapshot)
    }

    @Test
    func rendersVersionInformationAndAlignmentPatterns() throws {
        let options = QROptions(
            version: .v7,
            encodingMode: .alphanumeric,
            errorCorrectionLevel: .Q,
            mask: .pattern3
        )

        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )

        let result = QRTextRenderer.render(
            qrCode,
            mode: .debug
        )

        let rows = result
            .split(separator: "\n")
            .map { $0.split(separator: " ") }

        try #require(rows.count == qrCode.size)
        try #require(rows.allSatisfy { $0.count == qrCode.size })

        let versionInformationCoordinate = qrCode.size - 11

        #expect(rows[0][versionInformationCoordinate] == "V")
        #expect(rows[versionInformationCoordinate][0] == "V")

        #expect(rows[22][22] == "A")

        #expect(!result.contains("R"))
        #expect(!result.contains("?"))
    }
}

// MARK: - Reference Snapshots

private extension QRTextRendererDebugTests {
    static let version1QMask0DebugReferenceSnapshot = """
        F F F F F F F S I 1 0 0 0 S F F F F F F F
        F F F F F F F S I 0 0 1 0 S F F F F F F F
        F F F F F F F S I 0 0 1 1 S F F F F F F F
        F F F F F F F S I 0 0 0 0 S F F F F F F F
        F F F F F F F S I 0 1 0 0 S F F F F F F F
        F F F F F F F S I 0 1 0 0 S F F F F F F F
        F F F F F F F S T T T T T S F F F F F F F
        S S S S S S S S I 0 0 0 0 S S S S S S S S
        I I I I I I T I I 0 0 0 1 I I I I I I I I
        0 1 0 0 0 0 T 0 1 1 1 1 0 0 0 0 1 0 0 0 1
        0 0 1 1 0 1 T 1 0 1 1 0 0 0 1 0 1 1 0 0 0
        0 1 1 0 1 1 T 1 0 0 1 1 0 1 0 1 0 1 1 1 0
        1 0 0 0 1 0 T 0 1 0 1 1 1 0 1 1 1 0 1 0 1
        S S S S S S S S D 1 0 1 0 0 1 0 0 0 1 0 1
        F F F F F F F S I 0 1 0 0 0 0 1 0 1 1 0 0
        F F F F F F F S I 1 0 1 1 0 1 1 0 1 0 0 0
        F F F F F F F S I 0 1 0 0 0 1 1 1 1 1 1 1
        F F F F F F F S I 1 0 1 0 1 0 1 0 0 0 1 0
        F F F F F F F S I 0 0 1 0 1 1 1 0 1 0 0 1
        F F F F F F F S I 0 1 1 1 1 0 0 0 1 0 1 1
        F F F F F F F S I 0 0 1 0 1 1 1 0 0 0 0 1
        """
}
