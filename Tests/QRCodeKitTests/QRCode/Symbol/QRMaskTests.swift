//
//  QRMaskTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 27.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRMaskTests {
    @Test(arguments: patternTestCases)
    func evaluatePatternCorrectly(
        mask: QRMask,
        expectedRows: [String]
    ) {
        for (row, expectedRow) in expectedRows.enumerated() {
            for (column, expectedValue) in expectedRow.enumerated() {
                let expectedResult = expectedValue == "1"
                let result = mask.shouldInvert(
                    atRow: row,
                    column: column
                )

                #expect(result == expectedResult)
            }
        }
    }
}

// MARK: - Pattern Test Cases

private extension QRMaskTests {
    typealias PatternTestCase = (
        mask: QRMask,
        expectedRows: [String]
    )

    static let patternTestCases: [PatternTestCase] = [
        (.pattern0, [
            "101010",
            "010101",
            "101010",
            "010101",
            "101010",
            "010101"
        ]),
        (.pattern1, [
            "111111",
            "000000",
            "111111",
            "000000",
            "111111",
            "000000"
        ]),
        (.pattern2, [
            "100100",
            "100100",
            "100100",
            "100100",
            "100100",
            "100100"
        ]),
        (.pattern3, [
            "100100",
            "001001",
            "010010",
            "100100",
            "001001",
            "010010"
        ]),
        (.pattern4, [
            "111000",
            "111000",
            "000111",
            "000111",
            "111000",
            "111000"
        ]),
        (.pattern5, [
            "111111",
            "100000",
            "100100",
            "101010",
            "100100",
            "100000"
        ]),
        (.pattern6, [
            "111111",
            "111000",
            "110110",
            "101010",
            "101101",
            "100011"
        ]),
        (.pattern7, [
            "101010",
            "000111",
            "100011",
            "010101",
            "111000",
            "011100"
        ])
    ]
}
