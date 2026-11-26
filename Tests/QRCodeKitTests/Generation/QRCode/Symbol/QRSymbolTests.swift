//
//  QRSymbolTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.11.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct QRSymbolTests {
    @Test
    func providesModuleColorsRowByRow() {
        let matrix = QRMatrix.filled(version: .v1, color: Self.triangleColor)
        let symbol = QRSymbol(matrix: matrix, mask: .pattern0)

        let expectedColors = (0..<symbol.size).map { row in
            (0..<symbol.size).map { column in
                Self.triangleColor(row, column)
            }
        }

        #expect(symbol.moduleColors == expectedColors)
    }
}

// MARK: - Test Data

private extension QRSymbolTests {
    /// Dark below the diagonal, so swapping rows
    /// and columns changes the colors.
    static func triangleColor(
        _ row: Int,
        _ column: Int
    ) -> QRModuleColor {
        row > column ? .dark : .light
    }
}
