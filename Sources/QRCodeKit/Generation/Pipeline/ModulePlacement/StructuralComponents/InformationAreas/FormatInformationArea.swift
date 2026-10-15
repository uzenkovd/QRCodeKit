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

    static func place(
        in matrix: inout QRMatrix,
        errorCorrectionLevel: ErrorCorrectionLevel,
        mask: QRMask
    ) {
        let information = encodedValue(
            for: errorCorrectionLevel,
            mask: mask
        )

        for index in 0..<bitCount {
            let bit = (information >> index) & 1
            let color: QRModuleColor = bit == 1 ? .dark : .light
            let positions = bitPositions(
                for: index,
                matrixSize: matrix.size
            )

            placeModule(
                at: positions.firstCopy,
                color: color,
                in: &matrix
            )
            placeModule(
                at: positions.secondCopy,
                color: color,
                in: &matrix
            )
        }
    }
}

// MARK: - Information Encoding

private extension FormatInformationArea {
    static let maskBitCount = 3
    static let generatorPolynomial: UInt32 = 0x537
    static let remainderBitCount = 10
    static let formatMask: UInt32 = 0x5412

    static func encodedValue(
        for level: ErrorCorrectionLevel,
        mask: QRMask
    ) -> UInt32 {
        let levelIndicator = level.formatIndicator
        let maskIndicator = UInt32(mask.rawValue)
        let data = (levelIndicator << maskBitCount) | maskIndicator

        let codeword = BCHEncoder.encode(
            data,
            generator: generatorPolynomial,
            remainderBitCount: remainderBitCount
        )

        return codeword ^ formatMask
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
                row: index,
                column: formatCoordinate
            )

        case 6...7:
            firstCopy = Position(
                row: index + 1,
                column: formatCoordinate
            )

        case 8:
            firstCopy = Position(
                row: formatCoordinate,
                column: formatCoordinate - 1
            )

        case 9..<bitCount:
            firstCopy = Position(
                row: formatCoordinate,
                column: bitCount - 1 - index
            )

        default:
            preconditionFailure(
                "Format information bit index is out of range"
            )
        }

        let secondCopy: Position

        if index < 8 {
            secondCopy = Position(
                row: formatCoordinate,
                column: matrixSize - 1 - index
            )
        } else {
            secondCopy = Position(
                row: matrixSize - bitCount + index,
                column: formatCoordinate
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

// MARK: - Module Placement

private extension FormatInformationArea {
    static func placeModule(
        at position: Position,
        color: QRModuleColor,
        in matrix: inout QRMatrix
    ) {
        switch matrix[position.row, position.column] {
        case .reserved(.format),
             .information(type: .format, color: _):
            matrix[position.row, position.column] = .information(
                type: .format,
                color: color
            )

        default:
            preconditionFailure(
                "Format information can only be placed on reserved or existing format information modules"
            )
        }
    }
}
