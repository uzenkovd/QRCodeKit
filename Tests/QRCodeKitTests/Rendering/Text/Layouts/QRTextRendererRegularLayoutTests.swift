//
//  QRTextRendererRegularLayoutTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 03.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererRegularLayoutTests {
    @Test
    func splitsGridIntoRows() {
        // An asymmetric pattern: transposed or shifted rows
        // cannot match it by accident.
        let pattern: (Int, Int) -> QRModuleColor = { row, column in
            row.isMultiple(of: 2) && column < row ? .dark : .light
        }

        let matrix = QRMatrix.filled(version: .v1, color: pattern)

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        let lines = QRTextRenderer.regularLines(of: grid)

        let expectedLines = (0..<grid.size).map { row in
            (0..<grid.size).map { column in
                pattern(row, column)
            }
        }

        #expect(lines == expectedLines)
    }
}
