//
//  QRSymbol.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.10.2026.
//

/// A finalized symbol: a masked matrix with format
/// and version information in place.
struct QRSymbol: Equatable {
    let matrix: QRMatrix
    let mask: QRMask

    init(
        matrix: QRMatrix,
        mask: QRMask
    ) {
        precondition(
            matrix.isComplete,
            "A symbol cannot contain unset or reserved modules"
        )

        self.matrix = matrix
        self.mask = mask
    }

    var size: Int {
        matrix.size
    }
}

// MARK: - Module Colors

extension QRSymbol {
    /// The colors of all modules, row by row.
    var moduleColors: [[QRModuleColor]] {
        (0..<size).map { row in
            (0..<size).map { column in
                // Never nil: init checks that the matrix is complete
                matrix[row, column].color!
            }
        }
    }
}
