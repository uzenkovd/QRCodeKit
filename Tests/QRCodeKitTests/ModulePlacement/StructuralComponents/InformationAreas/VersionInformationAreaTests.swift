//
//  VersionInformationAreaTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 22.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct VersionInformationAreaTests {
    @Test(arguments: QRVersion.allCases.filter {
        $0.rawValue < 7
    })
    func leaveAllModulesUnsetBeforeVersion7(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                #expect(matrix[row, column] == .unset)
            }
        }
    }

    @Test(arguments: QRVersion.allCases.filter {
        $0.rawValue >= 7
    })
    func reserveVersionInformationAreaAtCorrectPositions(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let expectedPositions = Self.expectedPositions(
            matrixSize: matrix.size
        )

        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )

        for position in expectedPositions {
            #expect(
                matrix[position.row, position.column]
                    == .reserved(.version)
            )
        }
    }

    @Test(arguments: QRVersion.allCases.filter {
        $0.rawValue >= 7
    })
    func leaveOtherModulesUnset(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let expectedPositions = Self.expectedPositions(
            matrixSize: matrix.size
        )

        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )

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

private extension VersionInformationAreaTests {
    static let areaOffset = 11
    static let longSideLength = 6
    static let shortSideLength = 3

    struct Position: Hashable {
        let row: Int
        let column: Int
    }

    static func expectedPositions(
        matrixSize: Int
    ) -> Set<Position> {
        let farStartCoordinate = matrixSize - areaOffset

        let nearRange = 0..<longSideLength
        let farRange =
            farStartCoordinate..<(farStartCoordinate + shortSideLength)

        var positions: Set<Position> = []

        for row in nearRange {
            for column in farRange {
                positions.insert(
                    Position(
                        row: row,
                        column: column
                    )
                )
            }
        }

        for row in farRange {
            for column in nearRange {
                positions.insert(
                    Position(
                        row: row,
                        column: column
                    )
                )
            }
        }

        return positions
    }
}
