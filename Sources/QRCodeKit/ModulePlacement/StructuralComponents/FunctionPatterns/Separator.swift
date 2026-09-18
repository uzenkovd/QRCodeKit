//
//  Separator.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.09.2026.
//

enum Separator {
    static func place(in matrix: inout QRMatrix) {
        placeTopLeft(in: &matrix)
        placeTopRight(in: &matrix)
        placeBottomLeft(in: &matrix)
    }
}

// MARK: - Pattern Placement

private extension Separator {
    static let length = 8

    static func placeTopLeft(in matrix: inout QRMatrix) {
        placeAtCorner(
            row: length - 1,
            column: length - 1,
            rowStep: -1,
            columnStep: -1,
            in: &matrix
        )
    }

    static func placeTopRight(in matrix: inout QRMatrix) {
        placeAtCorner(
            row: length - 1,
            column: matrix.size - length,
            rowStep: -1,
            columnStep: 1,
            in: &matrix
        )
    }

    static func placeBottomLeft(in matrix: inout QRMatrix) {
        placeAtCorner(
            row: matrix.size - length,
            column: length - 1,
            rowStep: 1,
            columnStep: -1,
            in: &matrix
        )
    }

    static func placeAtCorner(
        row cornerRow: Int,
        column cornerColumn: Int,
        rowStep: Int,
        columnStep: Int,
        in matrix: inout QRMatrix
    ) {
        placeModule(
            atRow: cornerRow,
            column: cornerColumn,
            in: &matrix
        )

        for offset in 1..<length {
            placeModule(
                atRow: cornerRow + offset * rowStep,
                column: cornerColumn,
                in: &matrix
            )

            placeModule(
                atRow: cornerRow,
                column: cornerColumn + offset * columnStep,
                in: &matrix
            )
        }
    }

    static func placeModule(
        atRow row: Int,
        column: Int,
        in matrix: inout QRMatrix
    ) {
        precondition(
            matrix[row, column] == .unset,
            "Separator can only be placed on unset modules"
        )

        matrix[row, column] = .function(
            pattern: .separator,
            color: .light
        )
    }
}
