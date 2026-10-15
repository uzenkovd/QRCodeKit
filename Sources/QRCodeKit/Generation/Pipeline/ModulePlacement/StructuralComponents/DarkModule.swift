//
//  DarkModule.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.09.2026.
//

enum DarkModule {
    static func place(
        in matrix: inout QRMatrix
    ) {
        let row = matrix.size - 8
        let column = 8

        precondition(
            matrix[row, column] == .unset,
            "Dark module can only be placed on an unset module"
        )

        matrix[row, column] = .darkModule
    }
}
