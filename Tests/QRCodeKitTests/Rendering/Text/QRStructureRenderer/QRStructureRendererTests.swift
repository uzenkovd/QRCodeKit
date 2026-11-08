//
//  QRStructureRendererTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRStructureRendererTests {
    // MARK: - Matrix Rendering

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

        let result = QRStructureRenderer.render(matrix)
        let modules = Self.modules(in: result, size: matrix.size)

        try #require(modules.count == matrix.size)
        try #require(modules.allSatisfy { $0.count == matrix.size })

        #expect(modules[0][0] == "1")
        #expect(modules[0][lastIndex] == "F")
        #expect(modules[10][7] == "i")
        #expect(modules[lastIndex][0] == "R")
        #expect(modules[lastIndex][lastIndex] == "D")
    }

    @Test(arguments: QRVersion.allCases)
    func rendersExactMatrixDimensions(
        version: QRVersion
    ) {
        let matrix = QRMatrix(version: version)

        let result = QRStructureRenderer.render(matrix)
        let modules = Self.modules(in: result, size: matrix.size)

        #expect(modules.count == matrix.size)
        #expect(modules.allSatisfy { row in
            row.count == matrix.size && row.allSatisfy { $0 == "?" }
        })
        #expect(!result.hasSuffix("\n"))
    }

    // MARK: - QRCode Rendering

    @Test
    func matchesVersion1Reference() throws {
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

        let result = QRStructureRenderer.render(qrCode)

        #expect(result == Self.version1Reference)
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

        let result = QRStructureRenderer.render(qrCode.matrix)
        let modules = Self.modules(in: result, size: qrCode.size)

        try #require(modules.count == qrCode.size)
        try #require(modules.allSatisfy { $0.count == qrCode.size })

        let versionInformationCoordinate = qrCode.size - 11

        #expect(modules[0][versionInformationCoordinate].lowercased() == "v")
        #expect(modules[versionInformationCoordinate][0].lowercased() == "v")

        #expect(modules[22][22] == "A")

        #expect(!modules.joined().contains("R"))
        #expect(!modules.joined().contains("?"))
    }
}

// MARK: - Parsing Support

private extension QRStructureRendererTests {
    /// Removes the column ruler, the borders and the row labels
    /// and splits every row into the characters of its modules.
    static func modules(
        in rendered: String,
        size: Int
    ) -> [[Substring]] {
        let labelWidth = String(size - 1).count

        return rendered
            .split(separator: "\n", omittingEmptySubsequences: false)
            .dropFirst(labelWidth + 1)
            .dropLast()
            .map { $0.dropFirst(labelWidth + 3).dropLast(2).split(separator: " ") }
    }
}

// MARK: - Reference Snapshots

private extension QRStructureRendererTests {
    static let version1Reference = """
        Version 1-Q, alphanumeric mode, mask 0, 21×21 modules

                                 1                   2
             0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
           ┌───────────────────────────────────────────┐
         0 │ F F F F F F F s I 1 0 0 0 s F F F F F F F │
         1 │ F f f f f f F s I 0 0 1 0 s F f f f f f F │
         2 │ F f F F F f F s I 0 0 1 1 s F f F F F f F │
         3 │ F f F F F f F s I 0 0 0 0 s F f F F F f F │
         4 │ F f F F F f F s I 0 1 0 0 s F f F F F f F │
         5 │ F f f f f f F s i 0 1 0 0 s F f f f f f F │
         6 │ F F F F F F F s T t T t T s F F F F F F F │
         7 │ s s s s s s s s I 0 0 0 0 s s s s s s s s │
         8 │ i I I i I i T I i 0 0 0 1 i I i I I I I I │
         9 │ 0 1 0 0 0 0 t 0 1 1 1 1 0 0 0 0 1 0 0 0 1 │
        10 │ 0 0 1 1 0 1 T 1 0 1 1 0 0 0 1 0 1 1 0 0 0 │
        11 │ 0 1 1 0 1 1 t 1 0 0 1 1 0 1 0 1 0 1 1 1 0 │
        12 │ 1 0 0 0 1 0 T 0 1 0 1 1 1 0 1 1 1 0 1 0 1 │
        13 │ s s s s s s s s D 1 0 1 0 0 1 0 0 0 1 0 1 │
        14 │ F F F F F F F s I 0 1 0 0 0 0 1 0 1 1 0 0 │
        15 │ F f f f f f F s i 1 0 1 1 0 1 1 0 1 0 0 0 │
        16 │ F f F F F f F s I 0 1 0 0 0 1 1 1 1 1 1 1 │
        17 │ F f F F F f F s i 1 0 1 0 1 0 1 0 0 0 1 0 │
        18 │ F f F F F f F s I 0 0 1 0 1 1 1 0 1 0 0 1 │
        19 │ F f f f f f F s I 0 1 1 1 1 0 0 0 1 0 1 1 │
        20 │ F F F F F F F s i 0 0 1 0 1 1 1 0 0 0 0 1 │
           └───────────────────────────────────────────┘

        Dark and light modules:
        F f  finder pattern      A a  alignment pattern
        S s  separator           T t  timing pattern
        I i  format information  V v  version information
        D    dark module         1 0  data and error correction
        """
}
