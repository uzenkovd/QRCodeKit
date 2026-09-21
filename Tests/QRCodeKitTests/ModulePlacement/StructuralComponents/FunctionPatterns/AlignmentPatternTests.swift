//
//  AlignmentPatternTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct AlignmentPatternTests {
    @Test(arguments: QRVersion.allCases)
    func placeAlignmentPatternsAtCorrectPositions(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let centers = Self.expectedCenters(
            for: version
        )

        AlignmentPattern.place(
            in: &matrix,
            version: version
        )

        for center in centers {
            Self.expectAlignmentPattern(
                in: matrix,
                centeredAtRow: center.row,
                column: center.column
            )
        }
    }

    @Test(arguments: [
        QRVersion.v1,
        .v2,
        .v7,
        .max
    ])
    func leaveOtherModulesUnset(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let centers = Self.expectedCenters(
            for: version
        )

        AlignmentPattern.place(
            in: &matrix,
            version: version
        )

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                if matrix[row, column] != .unset {
                    #expect(
                        Self.isAlignmentPatternModule(
                            row: row,
                            column: column,
                            centers: centers
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Test Helpers

private extension AlignmentPatternTests {
    typealias Center = (
        row: Int,
        column: Int
    )

    static let patternSize = 5

    static let expectedPattern: [[QRModuleColor]] = [
        [.dark, .dark,  .dark,  .dark,  .dark],
        [.dark, .light, .light, .light, .dark],
        [.dark, .light, .dark,  .light, .dark],
        [.dark, .light, .light, .light, .dark],
        [.dark, .dark,  .dark,  .dark,  .dark]
    ]

    static func expectedCenters(
        for version: QRVersion
    ) -> [Center] {
        let coordinates =
            AlignmentPatternCenters.coordinates(
                for: version
            )

        guard !coordinates.isEmpty else {
            return []
        }

        let lastIndex = coordinates.count - 1

        return coordinates.enumerated().flatMap { rowIndex, row in
            coordinates.enumerated().compactMap { columnIndex, column in
                switch (rowIndex, columnIndex) {
                case (0, 0),
                     (0, lastIndex),
                     (lastIndex, 0):
                    return nil

                default:
                    return (
                        row: row,
                        column: column
                    )
                }
            }
        }
    }

    static func expectAlignmentPattern(
        in matrix: QRMatrix,
        centeredAtRow centerRow: Int,
        column centerColumn: Int
    ) {
        let startRow =
            centerRow - patternSize / 2
        let startColumn =
            centerColumn - patternSize / 2

        for row in 0..<patternSize {
            for column in 0..<patternSize {
                let expectedModule = QRModule.function(
                    pattern: .alignment,
                    color: expectedPattern[row][column]
                )

                #expect(
                    matrix[startRow + row, startColumn + column]
                        == expectedModule
                )
            }
        }
    }

    static func isAlignmentPatternModule(
        row: Int,
        column: Int,
        centers: [Center]
    ) -> Bool {
        let radius = patternSize / 2

        return centers.contains { center in
            abs(row - center.row) <= radius &&
            abs(column - center.column) <= radius
        }
    }
}
