//
//  QRTextRendererANSIRegularTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 31.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererANSIRegularTests {
    // MARK: - Module Colors

    @Test
    func rendersModuleColors() throws {
        let matrix = QRMatrix.filled(version: .v1) { _, column in
            column.isMultiple(of: 2) ? .light : .dark
        }

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        let result = QRTextRenderer.renderANSIRegular(grid)

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        let expectedFirstRow =
            (0..<matrix.size)
                .map { $0.isMultiple(of: 2) ? Self.light : Self.dark }
                .map { $0 + "  " }
                .joined()
            + Self.reset

        #expect(firstRow == expectedFirstRow)
    }

    @Test
    func emitsOneColorForUniformRow() throws {
        let matrix = QRMatrix.filled(version: .v1) { _, _ in .light }

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        let result = QRTextRenderer.renderANSIRegular(grid)

        let firstRow = try #require(
            result.split(separator: "\n").first
        )

        let expectedFirstRow =
            Self.light
            + String(repeating: "  ", count: matrix.size)
            + Self.reset

        #expect(firstRow == expectedFirstRow)
    }

    // MARK: - Quiet Zone

    @Test(arguments: [0, 1, 4])
    func rendersQuietZone(
        width: Int
    ) {
        let matrix = QRMatrix.filled(version: .v1) { _, _ in .dark }

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: width
        )

        let result = QRTextRenderer.renderANSIRegular(grid)

        let rows = result.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        let padding = String(repeating: "  ", count: width)

        let quietZoneRow =
            Self.light
            + String(repeating: "  ", count: grid.size)
            + Self.reset

        let symbol =
            Self.dark
            + String(repeating: "  ", count: matrix.size)

        let matrixRow = width > 0
            ? Self.light + padding + symbol + Self.light + padding + Self.reset
            : symbol + Self.reset

        let expectedRows =
            Array(repeating: quietZoneRow, count: width)
            + Array(repeating: matrixRow, count: matrix.size)
            + Array(repeating: quietZoneRow, count: width)

        #expect(rows.map(String.init) == expectedRows)
    }
}

// MARK: - Escape Sequence Support

private extension QRTextRendererANSIRegularTests {
    static let light = "\u{1B}[48;5;231m"
    static let dark = "\u{1B}[48;5;16m"
    static let reset = "\u{1B}[0m"
}
