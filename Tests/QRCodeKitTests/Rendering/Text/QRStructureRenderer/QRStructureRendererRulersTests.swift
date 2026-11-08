//
//  QRStructureRendererRulersTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRStructureRendererRulersTests {
    @Test
    func numbersColumnsWithOneLinePerDigit() {
        let ruler = QRStructureRenderer.columnRuler(size: 12, indent: 0)

        // Every column takes 2 characters, so column 10 starts at 20.
        #expect(ruler == [
            String(repeating: " ", count: 2 * 10) + "1",
            "0 1 2 3 4 5 6 7 8 9 0 1"
        ])
    }

    @Test
    func showsHigherDigitsOnlyAtTheirMultiples() throws {
        let ruler = QRStructureRenderer.columnRuler(size: 101, indent: 0)

        try #require(ruler.count == 3)

        #expect(ruler[0] == String(repeating: " ", count: 2 * 100) + "1")
        #expect(ruler[1].filter { $0 != " " } == "1234567890")
    }

    @Test
    func indentsEveryLine() {
        let ruler = QRStructureRenderer.columnRuler(size: 12, indent: 3)

        #expect(ruler == [
            String(repeating: " ", count: 3 + 2 * 10) + "1",
            "   0 1 2 3 4 5 6 7 8 9 0 1"
        ])
    }

    @Test(arguments: [
        (5, 21, " 5"),
        (5, 177, "  5"),
        (176, 177, "176")
    ])
    func alignsRowNumbers(
        row: Int,
        size: Int,
        number: String
    ) {
        #expect(QRStructureRenderer.rowNumber(row, size: size) == number)
    }
}
