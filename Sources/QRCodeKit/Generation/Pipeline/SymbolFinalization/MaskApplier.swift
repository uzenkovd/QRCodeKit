//
//  MaskApplier.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.09.2026.
//

enum MaskApplier {
    static func apply(
        _ mask: QRMask,
        to matrix: inout QRMatrix
    ) {
        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                guard case let .data(color) = matrix[row, column] else {
                    continue
                }

                if mask.shouldInvert(
                    atRow: row,
                    column: column
                ) {
                    matrix[row, column] = .data(color: color.inverted)
                }
            }
        }
    }
}
