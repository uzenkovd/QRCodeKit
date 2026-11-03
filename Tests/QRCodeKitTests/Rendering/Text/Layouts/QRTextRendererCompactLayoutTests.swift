//
//  QRTextRendererCompactLayoutTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 03.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererCompactLayoutTests {
    @Test
    func pairsRowsIntoLines() throws {
        // An asymmetric pattern: swapped halves or shifted rows
        // cannot match it by accident.
        let pattern: (Int, Int) -> QRModuleColor = { row, column in
            row.isMultiple(of: 2) && column < row ? .dark : .light
        }

        let matrix = QRMatrix.filled(version: .v1, color: pattern)

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        let lines = QRTextRenderer.compactLines(of: grid)

        try #require(lines.count == (grid.size + 1) / 2)

        for (index, line) in lines.enumerated() {
            let upperRow = index * 2
            let lowerRow = upperRow + 1

            let expectedUpper = (0..<grid.size).map { column in
                pattern(upperRow, column)
            }

            // The last row of an odd-height grid has no lower module.
            let expectedLower = (0..<grid.size).map { column -> QRModuleColor? in
                lowerRow < grid.size ? pattern(lowerRow, column) : nil
            }

            #expect(line.map { $0.upper } == expectedUpper)
            #expect(line.map { $0.lower } == expectedLower)
        }
    }
}
