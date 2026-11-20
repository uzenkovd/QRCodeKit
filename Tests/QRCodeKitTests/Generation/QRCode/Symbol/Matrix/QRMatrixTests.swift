//
//  QRMatrixTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 17.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRMatrixTests {
    // MARK: - Initialization

    @Test
    func takesSizeFromVersion() {
        let matrix = QRMatrix(version: .v10)

        #expect(matrix.size == 57)
    }

    @Test
    func startsWithAllModulesUnset() {
        let matrix = QRMatrix(version: .v1)

        #expect(Self.modules(of: matrix).allSatisfy { $0 == .unset })
    }

    // MARK: - Module Access

    @Test(arguments: [
        (0, 0),
        (0, 20),
        (7, 13),
        (13, 7),
        (20, 0),
        (20, 20)
    ] as [(Int, Int)])
    func storesModuleOnlyAtItsCoordinates(
        row: Int,
        column: Int
    ) {
        var matrix = QRMatrix(version: .v1)

        matrix[row, column] = .darkModule

        #expect(matrix[row, column] == .darkModule)
        #expect(Self.modules(of: matrix).count(where: { $0 != .unset }) == 1)
    }

    // MARK: - Completeness

    @Test(arguments: [
        .function(pattern: .timing, color: .dark),
        .darkModule,
        .information(type: .format, color: .light),
        .data(color: .light)
    ] as [QRModule])
    func isCompleteWithEveryModuleFilledIn(
        module: QRModule
    ) {
        var matrix = QRMatrix.filled(version: .v1) { _, _ in .dark }
        matrix[20, 20] = module

        #expect(matrix.isComplete)
    }

    @Test(arguments: [
        .unset,
        .reserved(.format),
        .reserved(.version)
    ] as [QRModule])
    func isNotCompleteWithModuleNotFilledIn(
        module: QRModule
    ) {
        var matrix = QRMatrix.filled(version: .v1) { _, _ in .dark }
        matrix[20, 20] = module

        #expect(!matrix.isComplete)
    }
}

// MARK: - Test Data

private extension QRMatrixTests {
    static func modules(
        of matrix: QRMatrix
    ) -> [QRModule] {
        (0..<matrix.size).flatMap { row in
            (0..<matrix.size).map { column in
                matrix[row, column]
            }
        }
    }
}
