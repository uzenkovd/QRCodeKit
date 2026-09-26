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
    // MARK: - Reservation

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

    // MARK: - Placement

    @Test(arguments: placementTestCases)
    func placeFormatInformationAtCorrectPositions(
        errorCorrectionLevel: ErrorCorrectionLevel,
        mask: QRMask,
        expectedInformation: UInt32
    ) {
        var matrix = QRMatrix(version: .min)

        let expectedMatrix = Self.makeExpectedMatrix(
            for: .min,
            information: expectedInformation
        )

        FormatInformationArea.reserve(in: &matrix)
        FormatInformationArea.place(
            in: &matrix,
            errorCorrectionLevel: errorCorrectionLevel,
            mask: mask
        )

        #expect(matrix == expectedMatrix)
    }

    @Test
    func replacePreviouslyPlacedFormatInformation() {
        var matrix = QRMatrix(version: .min)

        let expectedMatrix = Self.makeExpectedMatrix(
            for: .min,
            information: 0b000100000111011
        )

        FormatInformationArea.reserve(in: &matrix)
        FormatInformationArea.place(
            in: &matrix,
            errorCorrectionLevel: .L,
            mask: .pattern0
        )
        FormatInformationArea.place(
            in: &matrix,
            errorCorrectionLevel: .H,
            mask: .pattern7
        )

        #expect(matrix == expectedMatrix)
    }
}

// MARK: - Placement Test Cases

private extension FormatInformationAreaTests {
    typealias PlacementTestCase = (
        errorCorrectionLevel: ErrorCorrectionLevel,
        mask: QRMask,
        expectedInformation: UInt32
    )

    static let placementTestCases: [PlacementTestCase] = [
        (.L, .pattern0, 0b111011111000100),
        (.L, .pattern1, 0b111001011110011),
        (.L, .pattern2, 0b111110110101010),
        (.L, .pattern3, 0b111100010011101),
        (.L, .pattern4, 0b110011000101111),
        (.L, .pattern5, 0b110001100011000),
        (.L, .pattern6, 0b110110001000001),
        (.L, .pattern7, 0b110100101110110),

        (.M, .pattern0, 0b101010000010010),
        (.M, .pattern1, 0b101000100100101),
        (.M, .pattern2, 0b101111001111100),
        (.M, .pattern3, 0b101101101001011),
        (.M, .pattern4, 0b100010111111001),
        (.M, .pattern5, 0b100000011001110),
        (.M, .pattern6, 0b100111110010111),
        (.M, .pattern7, 0b100101010100000),

        (.Q, .pattern0, 0b011010101011111),
        (.Q, .pattern1, 0b011000001101000),
        (.Q, .pattern2, 0b011111100110001),
        (.Q, .pattern3, 0b011101000000110),
        (.Q, .pattern4, 0b010010010110100),
        (.Q, .pattern5, 0b010000110000011),
        (.Q, .pattern6, 0b010111011011010),
        (.Q, .pattern7, 0b010101111101101),

        (.H, .pattern0, 0b001011010001001),
        (.H, .pattern1, 0b001001110111110),
        (.H, .pattern2, 0b001110011100111),
        (.H, .pattern3, 0b001100111010000),
        (.H, .pattern4, 0b000011101100010),
        (.H, .pattern5, 0b000001001010101),
        (.H, .pattern6, 0b000110100001100),
        (.H, .pattern7, 0b000100000111011)
    ]
}

// MARK: - Expected Matrix

private extension FormatInformationAreaTests {
    static let bitCount = 15

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
                type: .format,
                color: color
            )

            let firstCopy = positions.firstCopy[index]
            let secondCopy = positions.secondCopy[index]

            matrix[firstCopy.row, firstCopy.column] = module
            matrix[secondCopy.row, secondCopy.column] = module
        }

        return matrix
    }
}

// MARK: - Expected Positions

private extension FormatInformationAreaTests {
    static let formatCoordinate = 8

    struct Position: Hashable {
        let row: Int
        let column: Int
    }

    typealias BitPositions = (
        firstCopy: [Position],
        secondCopy: [Position]
    )

    static func expectedPositions(
        matrixSize: Int
    ) -> Set<Position> {
        let positions = expectedBitPositions(
            matrixSize: matrixSize
        )

        return Set(positions.firstCopy + positions.secondCopy)
    }

    static func expectedBitPositions(
        matrixSize: Int
    ) -> BitPositions {
        let lastCoordinate = matrixSize - 1

        return (
            firstCopy: [
                Position(row: 0, column: formatCoordinate),
                Position(row: 1, column: formatCoordinate),
                Position(row: 2, column: formatCoordinate),
                Position(row: 3, column: formatCoordinate),
                Position(row: 4, column: formatCoordinate),
                Position(row: 5, column: formatCoordinate),
                Position(row: 7, column: formatCoordinate),
                Position(row: formatCoordinate, column: formatCoordinate),
                Position(row: formatCoordinate, column: 7),
                Position(row: formatCoordinate, column: 5),
                Position(row: formatCoordinate, column: 4),
                Position(row: formatCoordinate, column: 3),
                Position(row: formatCoordinate, column: 2),
                Position(row: formatCoordinate, column: 1),
                Position(row: formatCoordinate, column: 0)
            ],
            secondCopy: [
                Position(row: formatCoordinate, column: lastCoordinate),
                Position(row: formatCoordinate, column: lastCoordinate - 1),
                Position(row: formatCoordinate, column: lastCoordinate - 2),
                Position(row: formatCoordinate, column: lastCoordinate - 3),
                Position(row: formatCoordinate, column: lastCoordinate - 4),
                Position(row: formatCoordinate, column: lastCoordinate - 5),
                Position(row: formatCoordinate, column: lastCoordinate - 6),
                Position(row: formatCoordinate, column: lastCoordinate - 7),
                Position(row: lastCoordinate - 6, column: formatCoordinate),
                Position(row: lastCoordinate - 5, column: formatCoordinate),
                Position(row: lastCoordinate - 4, column: formatCoordinate),
                Position(row: lastCoordinate - 3, column: formatCoordinate),
                Position(row: lastCoordinate - 2, column: formatCoordinate),
                Position(row: lastCoordinate - 1, column: formatCoordinate),
                Position(row: lastCoordinate, column: formatCoordinate)
            ]
        )
    }
}
