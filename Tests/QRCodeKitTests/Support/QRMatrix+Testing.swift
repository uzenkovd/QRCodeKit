//
//  QRMatrix+Testing.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.10.2026.
//

@testable import QRCodeKit

extension QRMatrix {
    /// Creates a finalized matrix made entirely of data modules,
    /// colored by the given closure.
    static func filled(
        version: QRVersion,
        color: (_ row: Int, _ column: Int) -> QRModuleColor
    ) -> QRMatrix {
        var matrix = QRMatrix(version: version)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                matrix[row, column] = .data(
                    color: color(row, column)
                )
            }
        }

        return matrix
    }
}
