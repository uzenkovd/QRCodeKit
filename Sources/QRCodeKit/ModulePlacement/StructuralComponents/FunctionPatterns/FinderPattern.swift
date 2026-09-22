//
//  FinderPattern.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 17.09.2026.
//

enum FinderPattern {
    static func place(in matrix: inout QRMatrix) {
        let farStartCoordinate = matrix.size - size

        for row in 0..<size {
            for column in 0..<size {
                let color = color(
                    atRow: row,
                    column: column
                )

                placeModule(
                    atRow: row,
                    column: column,
                    color: color,
                    in: &matrix
                )
                placeModule(
                    atRow: row,
                    column: farStartCoordinate + column,
                    color: color,
                    in: &matrix
                )
                placeModule(
                    atRow: farStartCoordinate + row,
                    column: column,
                    color: color,
                    in: &matrix
                )
            }
        }
    }
}

// MARK: - Pattern Placement

private extension FinderPattern {
    static let size = 7

    static func color(
        atRow row: Int,
        column: Int
    ) -> QRModuleColor {
        let distanceToEdge = min(
            min(row, column),
            min(
                size - 1 - row,
                size - 1 - column
            )
        )

        return distanceToEdge == 1
            ? .light
            : .dark
    }

    static func placeModule(
        atRow row: Int,
        column: Int,
        color: QRModuleColor,
        in matrix: inout QRMatrix
    ) {
        precondition(
            matrix[row, column] == .unset,
            "Finder pattern can only be placed on unset modules"
        )

        matrix[row, column] = .function(
            pattern: .finder,
            color: color
        )
    }
}
