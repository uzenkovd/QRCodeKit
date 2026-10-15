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
    @Test
    func invertDataModulesAtMatchingPositions() {
        var matrix = QRMatrix(version: .min)

        matrix[1, 3] = .data(color: .light)
        matrix[2, 0] = .data(color: .dark)
        matrix[3, 1] = .data(color: .light)
        matrix[4, 2] = .data(color: .dark)

        var expectedMatrix = matrix
        expectedMatrix[1, 3] = .data(color: .dark)
        expectedMatrix[2, 0] = .data(color: .light)

        MaskApplier.apply(.pattern2, to: &matrix)

        #expect(matrix == expectedMatrix)
    }

    @Test
    func leaveNonDataModulesUnchanged() {
        var matrix = QRMatrix(version: .min)

        matrix[0, 2] = .reserved(.format)
        matrix[0, 4] = .reserved(.version)

        matrix[0, 6] = .function(
            pattern: .finder,
            color: .light
        )
        matrix[0, 8] = .function(
            pattern: .separator,
            color: .light
        )
        matrix[0, 10] = .function(
            pattern: .alignment,
            color: .light
        )
        matrix[0, 12] = .function(
            pattern: .timing,
            color: .dark
        )

        matrix[0, 14] = .darkModule

        matrix[0, 16] = .information(
            type: .format,
            color: .light
        )
        matrix[0, 18] = .information(
            type: .version,
            color: .dark
        )

        let expectedMatrix = matrix

        MaskApplier.apply(.pattern0, to: &matrix)

        #expect(matrix == expectedMatrix)
    }

    @Test
    func restoreDataModulesAfterApplyingSameMaskTwice() {
        var matrix = QRMatrix(version: .min)

        matrix[0, 2] = .data(color: .light)
        matrix[1, 0] = .data(color: .dark)

        let originalMatrix = matrix

        var expectedMaskedMatrix = matrix
        expectedMaskedMatrix[0, 2] = .data(color: .dark)

        MaskApplier.apply(.pattern7, to: &matrix)

        #expect(matrix == expectedMaskedMatrix)

        MaskApplier.apply(.pattern7, to: &matrix)

        #expect(matrix == originalMatrix)
    }
}
