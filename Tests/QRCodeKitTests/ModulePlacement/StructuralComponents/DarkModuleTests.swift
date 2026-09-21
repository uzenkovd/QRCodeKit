//
//  DarkModuleTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct DarkModuleTests {
    @Test(arguments: QRVersion.allCases)
    func placeDarkModuleAtCorrectPosition(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let expectedRow = 4 * version.rawValue + 9
        let expectedColumn = 8

        DarkModule.place(in: &matrix)

        #expect(
            matrix[expectedRow, expectedColumn]
                == .darkModule
        )
    }
}
