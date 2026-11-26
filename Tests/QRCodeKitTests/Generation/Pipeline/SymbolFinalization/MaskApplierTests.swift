//
//  MaskApplierTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.09.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct MaskApplierTests {
    @Test(arguments: QRMask.allCases)
    func invertsDataModulesWhereMaskConditionHolds(
        mask: QRMask
    ) {
        var matrix = Self.makeMatrix { row, column in
            .data(color: Self.checkerboardColor(row, column))
        }

        let expectedMatrix = Self.makeMatrix { row, column in
            let color = Self.checkerboardColor(row, column)
            let isInverted = mask.shouldInvert(atRow: row, column: column)

            return .data(color: isInverted ? color.inverted : color)
        }

        MaskApplier.apply(mask, to: &matrix)

        #expect(matrix == expectedMatrix)
    }

    @Test(
        arguments: [
            .unset,
            .reserved(.format),
            .function(pattern: .finder, color: .dark),
            .darkModule,
            .information(type: .version, color: .light),
        ] as [QRModule]
    )
    func leavesNonDataModulesUnchanged(
        module: QRModule
    ) {
        var matrix = Self.makeMatrix { _, _ in module }
        let originalMatrix = matrix

        MaskApplier.apply(.pattern0, to: &matrix)

        #expect(matrix == originalMatrix)
    }
}

// MARK: - Test Data

private extension MaskApplierTests {
    static func checkerboardColor(
        _ row: Int,
        _ column: Int
    ) -> QRModuleColor {
        (row + column).isMultiple(of: 2) ? .dark : .light
    }

    static func makeMatrix(
        module: (_ row: Int, _ column: Int) -> QRModule
    ) -> QRMatrix {
        var matrix = QRMatrix(version: .min)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                matrix[row, column] = module(row, column)
            }
        }

        return matrix
    }
}
