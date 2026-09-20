//
//  TimingPattern.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.09.2026.
//

enum TimingPattern {
    static func place(
        in matrix: inout QRMatrix
    ) {
        let endCoordinate = matrix.size - startCoordinate - 1

        for coordinate in startCoordinate...endCoordinate {
            let color = color(at: coordinate)

            placeModule(
                atRow: timingCoordinate,
                column: coordinate,
                color: color,
                in: &matrix
            )
            placeModule(
                atRow: coordinate,
                column: timingCoordinate,
                color: color,
                in: &matrix
            )
        }
    }
}

// MARK: - Pattern Placement

private extension TimingPattern {
    static let timingCoordinate = 6
    static let startCoordinate = 8

    static func color(
        at coordinate: Int
    ) -> QRModuleColor {
        coordinate.isMultiple(of: 2)
            ? .dark
            : .light
    }

    static func placeModule(
        atRow row: Int,
        column: Int,
        color: QRModuleColor,
        in matrix: inout QRMatrix
    ) {
        switch matrix[row, column] {
        case .unset:
            matrix[row, column] = .function(
                pattern: .timing,
                color: color
            )

        case let .function(
            pattern: .alignment,
            color: existingColor
        ):
            precondition(
                existingColor == color,
                "Timing pattern color must match overlapping alignment pattern"
            )

        default:
            preconditionFailure(
                "Timing pattern can only be placed on unset modules or overlap with alignment patterns"
            )
        }
    }
}
