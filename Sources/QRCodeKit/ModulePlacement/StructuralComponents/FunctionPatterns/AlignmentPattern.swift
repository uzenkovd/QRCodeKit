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
        let centers = validCenters(
            for: version
        )

        for center in centers {
            place(
                centeredAt: center,
                in: &matrix
            )
        }
    }
}

// MARK: - Pattern Placement

private extension AlignmentPattern {
    static let size = 5

    struct Center: Hashable {
        let row: Int
        let column: Int
    }

    static func validCenters(
        for version: QRVersion
    ) -> [Center] {
        let coordinates =
            AlignmentPatternCenters.coordinates(
                for: version
            )

        guard
            let firstCoordinate = coordinates.first,
            let lastCoordinate = coordinates.last
        else {
            return []
        }

        let allCenters = coordinates.flatMap { row in
            coordinates.map { column in
                Center(
                    row: row,
                    column: column
                )
            }
        }

        let excludedCenters: Set<Center> = [
            Center(
                row: firstCoordinate,
                column: firstCoordinate
            ),
            Center(
                row: firstCoordinate,
                column: lastCoordinate
            ),
            Center(
                row: lastCoordinate,
                column: firstCoordinate
            )
        ]

        return allCenters.filter { center in
            !excludedCenters.contains(center)
        }
    }

    static func place(
        centeredAt center: Center,
        in matrix: inout QRMatrix
    ) {
        let startRow = center.row - size / 2
        let startColumn = center.column - size / 2

        for row in 0..<size {
            for column in 0..<size {
                let matrixRow = startRow + row
                let matrixColumn = startColumn + column

                let distanceToEdge = min(
                    min(row, column),
                    min(
                        size - 1 - row,
                        size - 1 - column
                    )
                )

                let color: QRModuleColor =
                    distanceToEdge == 1 ? .light : .dark

                placeModule(
                    atRow: matrixRow,
                    column: matrixColumn,
                    color: color,
                    in: &matrix
                )
            }
        }
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
