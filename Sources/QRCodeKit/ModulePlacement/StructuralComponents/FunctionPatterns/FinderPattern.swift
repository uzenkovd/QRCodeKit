//
//  FinderPattern.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 17.09.2026.
//

enum FinderPattern {
    static func place(in matrix: inout QRMatrix) {
        placeTopLeft(in: &matrix)
        placeTopRight(in: &matrix)
        placeBottomLeft(in: &matrix)
    }
}

// MARK: - Pattern Placement

private extension FinderPattern {
    static let size = 7

    static func placeTopLeft(in matrix: inout QRMatrix) {
        place(
            atRow: 0,
            column: 0,
            in: &matrix
        )
    }

    static func placeTopRight(in matrix: inout QRMatrix) {
        place(
            atRow: 0,
            column: matrix.size - size,
            in: &matrix
        )
    }

    static func placeBottomLeft(in matrix: inout QRMatrix) {
        place(
            atRow: matrix.size - size,
            column: 0,
            in: &matrix
        )
    }

    static func place(
        atRow startRow: Int,
        column startColumn: Int,
        in matrix: inout QRMatrix
    ) {
        for row in 0..<size {
            for column in 0..<size {
                let matrixRow = startRow + row
                let matrixColumn = startColumn + column

                precondition(
                    matrix[matrixRow, matrixColumn] == .unset,
                    "Finder pattern can only be placed on unset modules"
                )

                let distanceToEdge = min(
                    min(row, column),
                    min(
                        size - 1 - row,
                        size - 1 - column
                    )
                )

                let color: QRModuleColor =
                    distanceToEdge == 1 ? .light : .dark

                matrix[matrixRow, matrixColumn] = .function(
                    pattern: .finder,
                    color: color
                )
            }
        }
    }
}
