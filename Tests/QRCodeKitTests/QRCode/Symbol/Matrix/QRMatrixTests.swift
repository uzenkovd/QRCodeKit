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
    @Test
    func initializeWithVersionSize() {
        let matrix = QRMatrix(version: .v10)

        #expect(matrix.size == 57)
    }

    @Test
    func initializeModulesAsUnset() {
        let matrix = QRMatrix(version: .v1)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                #expect(matrix[row, column] == .unset)
            }
        }
    }

    @Test
    func storeModulesAtCoordinates() {
        var matrix = QRMatrix(version: .v1)

        matrix[0, 0] = .function(
            pattern: .finder,
            color: .dark
        )
        matrix[7, 13] = .data(color: .light)
        matrix[20, 20] = .reserved(.format)

        #expect(
            matrix[0, 0]
                == .function(
                    pattern: .finder,
                    color: .dark
                )
        )
        #expect(matrix[7, 13] == .data(color: .light))
        #expect(
            matrix[20, 20]
                == .reserved(.format)
        )
    }
}
