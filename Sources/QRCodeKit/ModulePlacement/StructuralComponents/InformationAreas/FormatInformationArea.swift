//
//  FormatInformationArea.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 21.09.2026.
//

enum FormatInformationArea {
    static func reserve(
        in matrix: inout QRMatrix
    ) {
        for index in 0..<bitCount {
            let positions = bitPositions(
                for: index,
                matrixSize: matrix.size
            )

            reserveModule(
                at: positions.firstCopy,
                in: &matrix
            )
            reserveModule(
                at: positions.secondCopy,
                in: &matrix
            )
        }
    }
}

// MARK: - Bit Positions

private extension FormatInformationArea {
    static let bitCount = 15
    static let formatCoordinate = 8

    struct Position {
        let row: Int
        let column: Int
    }

    struct BitPositions {
        let firstCopy: Position
        let secondCopy: Position
    }

    static func bitPositions(
        for index: Int,
        matrixSize: Int
    ) -> BitPositions {
        let firstCopy: Position

        switch index {
        case 0...5:
            firstCopy = Position(
                row: formatCoordinate,
                column: index
            )

        case 6...7:
            firstCopy = Position(
                row: formatCoordinate,
                column: index + 1
            )

        case 8:
            firstCopy = Position(
                row: formatCoordinate - 1,
                column: formatCoordinate
            )

        case 9..<bitCount:
            firstCopy = Position(
                row: bitCount - 1 - index,
                column: formatCoordinate
            )

        default:
            preconditionFailure(
                "Format information bit index is out of range"
            )
        }

        let secondCopy: Position

        if index < 7 {
            secondCopy = Position(
                row: matrixSize - 1 - index,
                column: formatCoordinate
            )
        } else {
            secondCopy = Position(
                row: formatCoordinate,
                column: matrixSize - bitCount + index
            )
        }

        return BitPositions(
            firstCopy: firstCopy,
            secondCopy: secondCopy
        )
    }
}

// MARK: - Module Reservation

private extension FormatInformationArea {
    static func reserveModule(
        at position: Position,
        in matrix: inout QRMatrix
    ) {
        precondition(
            matrix[position.row, position.column] == .unset,
            "Format information area can only be reserved on unset modules"
        )

        matrix[position.row, position.column] = .reserved(.format)
    }
}
