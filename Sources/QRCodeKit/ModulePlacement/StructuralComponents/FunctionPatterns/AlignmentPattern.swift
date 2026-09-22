//
//  AlignmentPattern.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.09.2026.
//

enum AlignmentPattern {
    static func place(
        in matrix: inout QRMatrix,
        version: QRVersion
    ) {
        let coordinates =
            AlignmentPatternCenters.coordinates(
                for: version
            )

        guard !coordinates.isEmpty else {
            return
        }

        let lastIndex = coordinates.index(
            before: coordinates.endIndex
        )

        for rowIndex in coordinates.indices {
            for columnIndex in coordinates.indices {
                guard !isFinderPatternPosition(
                    rowIndex: rowIndex,
                    columnIndex: columnIndex,
                    lastIndex: lastIndex
                ) else {
                    continue
                }

                place(
                    centeredAtRow: coordinates[rowIndex],
                    column: coordinates[columnIndex],
                    in: &matrix
                )
            }
        }
    }
}

// MARK: - Pattern Placement

private extension AlignmentPattern {
    static let size = 5

    static func isFinderPatternPosition(
        rowIndex: Int,
        columnIndex: Int,
        lastIndex: Int
    ) -> Bool {
        rowIndex == 0 && columnIndex == 0 ||
        rowIndex == 0 && columnIndex == lastIndex ||
        rowIndex == lastIndex && columnIndex == 0
    }

    static func place(
        centeredAtRow centerRow: Int,
        column centerColumn: Int,
        in matrix: inout QRMatrix
    ) {
        let startRow = centerRow - size / 2
        let startColumn = centerColumn - size / 2

        for row in 0..<size {
            for column in 0..<size {
                let matrixRow = startRow + row
                let matrixColumn = startColumn + column
                let color = color(
                    atRow: row,
                    column: column
                )

                placeModule(
                    atRow: matrixRow,
                    column: matrixColumn,
                    color: color,
                    in: &matrix
                )
            }
        }
    }

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
            "Alignment pattern can only be placed on unset modules"
        )

        matrix[row, column] = .function(
            pattern: .alignment,
            color: color
        )
    }
}
