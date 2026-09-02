//
//  ReedSolomonEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 02.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct ReedSolomonEncoderTests {
    // MARK: - Generator Polynomial

    @Test(arguments: [1, 2, 3, 7, 10, 30, 64, 128, 192, 255])
    func generatorPolynomialHasRequestedDegree(degree: Int) {
        let generator = ReedSolomonEncoder.generatorPolynomial(
            degree: degree
        )

        #expect(generator.degree == degree)
    }

    @Test(arguments: [
        (1, [1, 1]),
        (2, [1, 3, 2]),
        (3, [1, 7, 14, 8]),
        (7, [1, 127, 122, 154, 164, 11, 68, 117]),
        (10, [1, 216, 194, 159, 111, 199, 94, 95, 113, 157, 193])
    ])
    func generatorPolynomialForKnownDegrees(
        degree: Int,
        expected: [UInt8]
    ) {
        let generator = ReedSolomonEncoder.generatorPolynomial(
            degree: degree
        )

        #expect(generator == Polynomial(expected))
    }
}
