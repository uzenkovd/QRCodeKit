//
//  SeparatorTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct SeparatorTests {
    @Test(arguments: QRVersion.allCases)
    func placeSeparatorsAtCorrectPositions(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        Separator.place(in: &matrix)

        Self.expectTopLeftSeparator(in: matrix)
        Self.expectTopRightSeparator(in: matrix)
        Self.expectBottomLeftSeparator(in: matrix)
    }

    @Test(arguments: [
        QRVersion.min,
        .max
    ])
    func leaveOtherModulesUnset(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        Separator.place(in: &matrix)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                if matrix[row, column] != .unset {
                    #expect(
                        Self.isSeparatorModule(
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

private extension SeparatorTests {
    static let separatorLength = 8

    static let expectedModule = QRModule.function(
        pattern: .separator,
        color: .light
    )

    static func expectTopLeftSeparator(
        in matrix: QRMatrix
    ) {
        for offset in 0..<separatorLength {
            #expect(
                matrix[separatorLength - 1, offset]
                    == expectedModule
            )
            #expect(
                matrix[offset, separatorLength - 1]
                    == expectedModule
            )
        }
    }

    static func expectTopRightSeparator(
        in matrix: QRMatrix
    ) {
        let startColumn = matrix.size - separatorLength

        for offset in 0..<separatorLength {
            #expect(
                matrix[separatorLength - 1, startColumn + offset]
                    == expectedModule
            )
            #expect(
                matrix[offset, startColumn]
                    == expectedModule
            )
        }
    }

    static func expectBottomLeftSeparator(
        in matrix: QRMatrix
    ) {
        let startRow = matrix.size - separatorLength

        for offset in 0..<separatorLength {
            #expect(
                matrix[startRow, offset]
                    == expectedModule
            )
            #expect(
                matrix[startRow + offset, separatorLength - 1]
                    == expectedModule
            )
        }
    }

    static func isSeparatorModule(
        row: Int,
        column: Int,
        matrixSize: Int
    ) -> Bool {
        let lastOffset = separatorLength - 1
        let oppositeOffset = matrixSize - separatorLength

        let isTopLeft =
            (row == lastOffset && column < separatorLength) ||
            (column == lastOffset && row < separatorLength)

        let isTopRight =
            (row == lastOffset && column >= oppositeOffset) ||
            (column == oppositeOffset && row < separatorLength)

        let isBottomLeft =
            (row == oppositeOffset && column < separatorLength) ||
            (column == lastOffset && row >= oppositeOffset)

        return isTopLeft || isTopRight || isBottomLeft
    }
}
