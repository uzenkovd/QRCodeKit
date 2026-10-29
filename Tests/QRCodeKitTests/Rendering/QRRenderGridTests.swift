//
//  QRRenderGridTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRRenderGridTests {
    // MARK: - Quiet Zone

    @Test(arguments: [0, 1, 2, 3, 4])
    func surroundsMatrixWithLightQuietZone(
        quietZoneWidth: Int
    ) throws {
        let matrix = QRMatrix.filled(version: .v1) { _, _ in .dark }

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: quietZoneWidth
        )

        let expectedSize = matrix.size + quietZoneWidth * 2
        let matrixRange = quietZoneWidth..<(quietZoneWidth + matrix.size)

        let expectedColors = (0..<expectedSize).map { row in
            (0..<expectedSize).map { column -> QRModuleColor in
                matrixRange.contains(row) && matrixRange.contains(column)
                    ? .dark
                    : .light
            }
        }

        try #require(grid.size == expectedSize)

        #expect(Self.colors(of: grid) == expectedColors)
    }

    // MARK: - Matrix Layout

    @Test(arguments: [0, 1, 4])
    func preservesMatrixLayout(
        quietZoneWidth: Int
    ) {
        // An asymmetric pattern: a transposed or shifted grid
        // cannot match it by accident.
        let pattern: (Int, Int) -> QRModuleColor = { row, column in
            row.isMultiple(of: 2) && column < row ? .dark : .light
        }

        let matrix = QRMatrix.filled(version: .v1, color: pattern)

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: quietZoneWidth
        )

        let symbolColors = Self.colors(of: grid)
            .dropFirst(quietZoneWidth)
            .prefix(matrix.size)
            .map { row in
                Array(row.dropFirst(quietZoneWidth).prefix(matrix.size))
            }

        let expectedColors = (0..<matrix.size).map { row in
            (0..<matrix.size).map { column in
                pattern(row, column)
            }
        }

        #expect(symbolColors == expectedColors)
    }

    // MARK: - Module Colors

    @Test(
        arguments: [
            (QRModule.data(color: .light), QRModuleColor.light),
            (.data(color: .dark), .dark),
            (.function(pattern: .finder, color: .light), .light),
            (.function(pattern: .finder, color: .dark), .dark),
            (.function(pattern: .separator, color: .light), .light),
            (.function(pattern: .alignment, color: .light), .light),
            (.function(pattern: .alignment, color: .dark), .dark),
            (.function(pattern: .timing, color: .light), .light),
            (.function(pattern: .timing, color: .dark), .dark),
            (.information(type: .format, color: .light), .light),
            (.information(type: .format, color: .dark), .dark),
            (.information(type: .version, color: .light), .light),
            (.information(type: .version, color: .dark), .dark),
            (.darkModule, .dark)
        ]
    )
    func resolvesModuleColor(
        module: QRModule,
        expectedColor: QRModuleColor
    ) {
        var matrix = QRMatrix.filled(version: .v1) { _, _ in .light }
        matrix[0, 0] = module

        let grid = QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: 0
        )

        #expect(grid[0, 0] == expectedColor)
    }
}

// MARK: - Grid Support

private extension QRRenderGridTests {
    static func colors(
        of grid: QRRenderGrid
    ) -> [[QRModuleColor]] {
        (0..<grid.size).map { row in
            (0..<grid.size).map { column in
                grid[row, column]
            }
        }
    }
}
