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
    // MARK: - Reservation

    @Test(arguments: QRVersion.allCases.filter {
        $0 < .v7
    })
    func leaveAllModulesUnsetWhenReservingBeforeVersion7(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)
        let expectedMatrix = matrix

        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )

        #expect(matrix == expectedMatrix)
    }

    @Test(arguments: QRVersion.allCases.filter {
        $0 >= .v7
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
        $0 >= .v7
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

    // MARK: - Placement

    @Test(arguments: QRVersion.allCases.filter {
        $0 < .v7
    })
    func leaveAllModulesUnsetWhenPlacingBeforeVersion7(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)
        let expectedMatrix = matrix

        VersionInformationArea.place(
            in: &matrix,
            version: version
        )

        #expect(matrix == expectedMatrix)
    }

    @Test(arguments: placementTestCases)
    func placeVersionInformationAtCorrectPositions(
        version: QRVersion,
        expectedInformation: UInt32
    ) {
        var matrix = QRMatrix(version: version)

        let expectedMatrix = Self.makeExpectedMatrix(
            for: version,
            information: expectedInformation
        )

        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )
        VersionInformationArea.place(
            in: &matrix,
            version: version
        )

        #expect(matrix == expectedMatrix)
    }
}

// MARK: - Placement Test Cases

private extension VersionInformationAreaTests {
    typealias PlacementTestCase = (
        version: QRVersion,
        expectedInformation: UInt32
    )

    static let placementTestCases: [PlacementTestCase] = [
        (.v7,  0b000111110010010100),
        (.v8,  0b001000010110111100),
        (.v9,  0b001001101010011001),
        (.v10, 0b001010010011010011),
        (.v11, 0b001011101111110110),
        (.v12, 0b001100011101100010),
        (.v13, 0b001101100001000111),
        (.v14, 0b001110011000001101),
        (.v15, 0b001111100100101000),
        (.v16, 0b010000101101111000),
        (.v17, 0b010001010001011101),
        (.v18, 0b010010101000010111),
        (.v19, 0b010011010100110010),
        (.v20, 0b010100100110100110),
        (.v21, 0b010101011010000011),
        (.v22, 0b010110100011001001),
        (.v23, 0b010111011111101100),
        (.v24, 0b011000111011000100),
        (.v25, 0b011001000111100001),
        (.v26, 0b011010111110101011),
        (.v27, 0b011011000010001110),
        (.v28, 0b011100110000011010),
        (.v29, 0b011101001100111111),
        (.v30, 0b011110110101110101),
        (.v31, 0b011111001001010000),
        (.v32, 0b100000100111010101),
        (.v33, 0b100001011011110000),
        (.v34, 0b100010100010111010),
        (.v35, 0b100011011110011111),
        (.v36, 0b100100101100001011),
        (.v37, 0b100101010000101110),
        (.v38, 0b100110101001100100),
        (.v39, 0b100111010101000001),
        (.v40, 0b101000110001101001)
    ]
}

// MARK: - Expected Matrix

private extension VersionInformationAreaTests {
    static let bitCount = 18

    static func makeExpectedMatrix(
        for version: QRVersion,
        information: UInt32
    ) -> QRMatrix {
        var matrix = QRMatrix(version: version)

        let positions = expectedBitPositions(
            matrixSize: matrix.size
        )

        for index in 0..<bitCount {
            let bit = (information >> index) & 1
            let color: QRModuleColor = bit == 1 ? .dark : .light
            let module = QRModule.information(
                type: .version,
                color: color
            )

            let topRightCopy = positions.topRightCopy[index]
            let bottomLeftCopy = positions.bottomLeftCopy[index]

            matrix[topRightCopy.row, topRightCopy.column] = module
            matrix[bottomLeftCopy.row, bottomLeftCopy.column] = module
        }

        return matrix
    }
}

// MARK: - Expected Positions

private extension VersionInformationAreaTests {
    static let areaOffset = 11

    struct Position: Hashable {
        let row: Int
        let column: Int
    }

    typealias BitPositions = (
        topRightCopy: [Position],
        bottomLeftCopy: [Position]
    )

    static func expectedPositions(
        matrixSize: Int
    ) -> Set<Position> {
        let positions = expectedBitPositions(
            matrixSize: matrixSize
        )

        return Set(positions.topRightCopy + positions.bottomLeftCopy)
    }

    static func expectedBitPositions(
        matrixSize: Int
    ) -> BitPositions {
        let farStartCoordinate = matrixSize - areaOffset

        return (
            topRightCopy: [
                Position(row: 0, column: farStartCoordinate),
                Position(row: 0, column: farStartCoordinate + 1),
                Position(row: 0, column: farStartCoordinate + 2),
                Position(row: 1, column: farStartCoordinate),
                Position(row: 1, column: farStartCoordinate + 1),
                Position(row: 1, column: farStartCoordinate + 2),
                Position(row: 2, column: farStartCoordinate),
                Position(row: 2, column: farStartCoordinate + 1),
                Position(row: 2, column: farStartCoordinate + 2),
                Position(row: 3, column: farStartCoordinate),
                Position(row: 3, column: farStartCoordinate + 1),
                Position(row: 3, column: farStartCoordinate + 2),
                Position(row: 4, column: farStartCoordinate),
                Position(row: 4, column: farStartCoordinate + 1),
                Position(row: 4, column: farStartCoordinate + 2),
                Position(row: 5, column: farStartCoordinate),
                Position(row: 5, column: farStartCoordinate + 1),
                Position(row: 5, column: farStartCoordinate + 2)
            ],
            bottomLeftCopy: [
                Position(row: farStartCoordinate, column: 0),
                Position(row: farStartCoordinate + 1, column: 0),
                Position(row: farStartCoordinate + 2, column: 0),
                Position(row: farStartCoordinate, column: 1),
                Position(row: farStartCoordinate + 1, column: 1),
                Position(row: farStartCoordinate + 2, column: 1),
                Position(row: farStartCoordinate, column: 2),
                Position(row: farStartCoordinate + 1, column: 2),
                Position(row: farStartCoordinate + 2, column: 2),
                Position(row: farStartCoordinate, column: 3),
                Position(row: farStartCoordinate + 1, column: 3),
                Position(row: farStartCoordinate + 2, column: 3),
                Position(row: farStartCoordinate, column: 4),
                Position(row: farStartCoordinate + 1, column: 4),
                Position(row: farStartCoordinate + 2, column: 4),
                Position(row: farStartCoordinate, column: 5),
                Position(row: farStartCoordinate + 1, column: 5),
                Position(row: farStartCoordinate + 2, column: 5)
            ]
        )
    }
}
