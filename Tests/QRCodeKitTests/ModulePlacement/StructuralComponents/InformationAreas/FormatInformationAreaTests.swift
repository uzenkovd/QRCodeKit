//
//  FormatInformationAreaTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 21.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct FormatInformationAreaTests {
    @Test(arguments: QRVersion.allCases)
    func reserveFormatInformationAreaAtCorrectPositions(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let expectedPositions = Self.expectedPositions(
            matrixSize: matrix.size
        )

        FormatInformationArea.reserve(in: &matrix)

        for position in expectedPositions {
            #expect(
                matrix[position.row, position.column]
                    == .reserved(.format)
            )
        }
    }

    @Test(arguments: QRVersion.allCases)
    func leaveOtherModulesUnset(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let expectedPositions = Self.expectedPositions(
            matrixSize: matrix.size
        )

        FormatInformationArea.reserve(in: &matrix)

        var unexpectedPosition: Position?

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                guard matrix[row, column] != .unset else {
                    continue
                }

                let position = Position(
                    row: row,
                    column: column
                )

                if !expectedPositions.contains(position) {
                    unexpectedPosition = position
                    break
                }
            }

            if unexpectedPosition != nil {
                break
            }
        }

        #expect(unexpectedPosition == nil)
    }
}

// MARK: - Test Helpers

private extension FormatInformationAreaTests {
    static let formatCoordinate = 8

    struct Position: Hashable {
        let row: Int
        let column: Int
    }

    static func expectedPositions(
        matrixSize: Int
    ) -> Set<Position> {
        var positions: Set<Position> = []

        for coordinate in 0...5 {
            positions.insert(
                Position(
                    row: formatCoordinate,
                    column: coordinate
                )
            )
            positions.insert(
                Position(
                    row: coordinate,
                    column: formatCoordinate
                )
            )
        }

        positions.insert(
            Position(
                row: formatCoordinate,
                column: formatCoordinate - 1
            )
        )
        positions.insert(
            Position(
                row: formatCoordinate,
                column: formatCoordinate
            )
        )
        positions.insert(
            Position(
                row: formatCoordinate - 1,
                column: formatCoordinate
            )
        )

        for row in (matrixSize - 7)..<matrixSize {
            positions.insert(
                Position(
                    row: row,
                    column: formatCoordinate
                )
            )
        }

        for column in (matrixSize - 8)..<matrixSize {
            positions.insert(
                Position(
                    row: formatCoordinate,
                    column: column
                )
            )
        }

        return positions
    }
}
