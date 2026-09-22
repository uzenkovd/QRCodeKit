//
//  FinderPatternTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 17.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct FinderPatternTests {
    @Test(arguments: QRVersion.allCases)
    func placeFinderPatternsAtCorrectPositions(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        FinderPattern.place(in: &matrix)

        Self.expectFinderPattern(
            in: matrix,
            atRow: 0,
            column: 0
        )
        Self.expectFinderPattern(
            in: matrix,
            atRow: 0,
            column: matrix.size - Self.patternSize
        )
        Self.expectFinderPattern(
            in: matrix,
            atRow: matrix.size - Self.patternSize,
            column: 0
        )
    }

    @Test(arguments: QRVersion.allCases)
    func leaveOtherModulesUnset(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        FinderPattern.place(in: &matrix)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                if matrix[row, column] != .unset {
                    #expect(
                        Self.isFinderPatternModule(
                            row: row,
                            column: column,
                            matrixSize: matrix.size
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Test Helpers

private extension FinderPatternTests {
    static let patternSize = 7

    static let expectedPattern: [[QRModuleColor]] = [
        [.dark, .dark,  .dark,  .dark,  .dark,  .dark,  .dark],
        [.dark, .light, .light, .light, .light, .light, .dark],
        [.dark, .light, .dark,  .dark,  .dark,  .light, .dark],
        [.dark, .light, .dark,  .dark,  .dark,  .light, .dark],
        [.dark, .light, .dark,  .dark,  .dark,  .light, .dark],
        [.dark, .light, .light, .light, .light, .light, .dark],
        [.dark, .dark,  .dark,  .dark,  .dark,  .dark,  .dark]
    ]

    static func expectFinderPattern(
        in matrix: QRMatrix,
        atRow startRow: Int,
        column startColumn: Int
    ) {
        for row in 0..<patternSize {
            for column in 0..<patternSize {
                let expectedModule = QRModule.function(
                    pattern: .finder,
                    color: expectedPattern[row][column]
                )

                #expect(
                    matrix[startRow + row, startColumn + column]
                        == expectedModule
                )
            }
        }
    }

    static func isFinderPatternModule(
        row: Int,
        column: Int,
        matrixSize: Int
    ) -> Bool {
        let isTopLeft =
            row < patternSize &&
            column < patternSize

        let isTopRight =
            row < patternSize &&
            column >= matrixSize - patternSize

        let isBottomLeft =
            row >= matrixSize - patternSize &&
            column < patternSize

        return isTopLeft || isTopRight || isBottomLeft
    }
}
