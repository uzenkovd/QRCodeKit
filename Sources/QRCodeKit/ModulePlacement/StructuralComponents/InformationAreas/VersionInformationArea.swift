//
//  VersionInformationArea.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 22.09.2026.
//

enum VersionInformationArea {
    static func reserve(
        in matrix: inout QRMatrix,
        version: QRVersion
    ) {
        guard version >= .v7 else {
            return
        }

        for index in 0..<bitCount {
            let positions = bitPositions(
                for: index,
                matrixSize: matrix.size
            )

            reserveModule(
                at: positions.topRightCopy,
                in: &matrix
            )
            reserveModule(
                at: positions.bottomLeftCopy,
                in: &matrix
            )
        }
    }

    static func place(
        in matrix: inout QRMatrix,
        version: QRVersion
    ) {
        guard version >= .v7 else {
            return
        }

        let information = encodedValue(for: version)

        for index in 0..<bitCount {
            let bit = (information >> index) & 1
            let color: QRModuleColor = bit == 1 ? .dark : .light
            let positions = bitPositions(
                for: index,
                matrixSize: matrix.size
            )

            placeModule(
                at: positions.topRightCopy,
                color: color,
                in: &matrix
            )
            placeModule(
                at: positions.bottomLeftCopy,
                color: color,
                in: &matrix
            )
        }
    }
}

// MARK: - Information Encoding

private extension VersionInformationArea {
    static let generatorPolynomial: UInt32 = 0x1F25
    static let remainderBitCount = 12

    static func encodedValue(
        for version: QRVersion
    ) -> UInt32 {
        let data = UInt32(version.rawValue)

        return BCHEncoder.encode(
            data,
            generator: generatorPolynomial,
            remainderBitCount: remainderBitCount
        )
    }
}

// MARK: - Bit Positions

private extension VersionInformationArea {
    static let bitCount = 18
    static let areaOffset = 11

    struct Position {
        let row: Int
        let column: Int
    }

    struct BitPositions {
        let topRightCopy: Position
        let bottomLeftCopy: Position
    }

    static func bitPositions(
        for index: Int,
        matrixSize: Int
    ) -> BitPositions {
        let groupIndex = index / 3
        let offsetInGroup = index % 3
        let farStartCoordinate = matrixSize - areaOffset

        return BitPositions(
            topRightCopy: Position(
                row: groupIndex,
                column: farStartCoordinate + offsetInGroup
            ),
            bottomLeftCopy: Position(
                row: farStartCoordinate + offsetInGroup,
                column: groupIndex
            )
        )
    }
}

// MARK: - Module Reservation

private extension VersionInformationArea {
    static func reserveModule(
        at position: Position,
        in matrix: inout QRMatrix
    ) {
        precondition(
            matrix[position.row, position.column] == .unset,
            "Version information area can only be reserved on unset modules"
        )

        matrix[position.row, position.column] = .reserved(.version)
    }
}

// MARK: - Module Placement

private extension VersionInformationArea {
    static func placeModule(
        at position: Position,
        color: QRModuleColor,
        in matrix: inout QRMatrix
    ) {
        precondition(
            matrix[position.row, position.column] == .reserved(.version),
            "Version information can only be placed on reserved version information modules"
        )

        matrix[position.row, position.column] = .information(
            type: .version,
            color: color
        )
    }
}
