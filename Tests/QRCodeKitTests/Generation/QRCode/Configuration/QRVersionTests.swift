//
//  QRVersionTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRVersionTests {
    // MARK: - Cases

    @Test
    func numbersVersionsFrom1Through40() {
        #expect(QRVersion.allCases.map(\.rawValue) == Array(1...40))
        #expect(QRVersion(rawValue: 0) == nil)
        #expect(QRVersion(rawValue: 41) == nil)
    }

    @Test
    func boundsAreFirstAndLastVersions() {
        #expect(QRVersion.min == .v1)
        #expect(QRVersion.max == .v40)
    }

    // MARK: - Size

    @Test(arguments: [
        (.v1, 21),
        (.v2, 25),
        (.v7, 45),
        (.v10, 57),
        (.v40, 177)
    ] as [(QRVersion, Int)])
    func matchesSpecificationSize(
        version: QRVersion,
        size: Int
    ) {
        #expect(version.size == size)
    }

    // MARK: - Comparison

    @Test
    func comparesByVersionNumber() {
        #expect(QRVersion.v1 < .v2)
        #expect(QRVersion.v39 < .v40)
        #expect(!(QRVersion.v7 < .v7))
        #expect(QRVersion.v7 >= .v7)
    }

    @Test
    func ordersCasesByVersionNumber() {
        #expect(QRVersion.allCases == QRVersion.allCases.sorted())
    }
}
