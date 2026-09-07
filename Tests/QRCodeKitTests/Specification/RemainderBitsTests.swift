//
//  RemainderBitsTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 07.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct RemainderBitsTests {
    @Test
    func bitCountForAllVersions() {
        let expectedBitCounts: [Int] =
            [0]
            + Array(repeating: 7, count: 5)
            + Array(repeating: 0, count: 7)
            + Array(repeating: 3, count: 7)
            + Array(repeating: 4, count: 7)
            + Array(repeating: 3, count: 7)
            + Array(repeating: 0, count: 6)

        #expect(expectedBitCounts.count == QRVersion.allCases.count)

        for (version, expectedBitCount) in zip(
            QRVersion.allCases,
            expectedBitCounts
        ) {
            #expect(RemainderBits.bitCount(for: version) == expectedBitCount)
        }
    }
}
