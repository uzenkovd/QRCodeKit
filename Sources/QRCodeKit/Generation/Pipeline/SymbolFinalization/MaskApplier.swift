//
//  MaskApplier.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.09.2026.
//

/// Inverts every data module where the mask condition holds,
/// leaving all other modules unchanged.
enum MaskApplier {
    static func apply(
        _ mask: QRMask,
        to matrix: inout QRMatrix
    ) {
        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                guard
                    case let .data(color) = matrix[row, column],
                    mask.shouldInvert(atRow: row, column: column)
                else {
                    continue
                }

                matrix[row, column] = .data(color: color.inverted)
            }
        }
    }
}
