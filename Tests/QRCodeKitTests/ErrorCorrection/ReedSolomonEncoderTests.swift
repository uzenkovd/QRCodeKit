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

    // MARK: - encode(_:errorCorrectionCodewordCount:)

    @Test(arguments: [1, 2, 5, 10, 30])
    func encodeReturnsRequestedErrorCorrectionCodewordCount(
        errorCorrectionCodewordCount: Int
    ) {
        let encoder = ReedSolomonEncoder()

        let result = encoder.encode(
            [1, 2, 3],
            errorCorrectionCodewordCount: errorCorrectionCodewordCount
        )

        #expect(result.count == errorCorrectionCodewordCount)
    }

    @Test(arguments: [1, 2, 5, 10, 30])
    func zeroDataProducesZeroErrorCorrectionCodewords(
        errorCorrectionCodewordCount: Int
    ) {
        let encoder = ReedSolomonEncoder()

        let result = encoder.encode(
            [0],
            errorCorrectionCodewordCount: errorCorrectionCodewordCount
        )

        let expected = Array(
            repeating: UInt8.zero,
            count: errorCorrectionCodewordCount
        )

        #expect(result == expected)
    }

    @Test
    func encodeRestoresLeadingZeroCodeword() {
        let encoder = ReedSolomonEncoder()

        let result = encoder.encode(
            [1, 246],
            errorCorrectionCodewordCount: 2
        )

        #expect(result == [0, 247])
    }

    @Test
    func encodeForKnownQRCodeBlock() {
        let encoder = ReedSolomonEncoder()

        let dataCodewords: [UInt8] = [
            32, 91, 11, 120, 209, 114, 220, 77,
            67, 64, 236, 17, 236, 17, 236, 17
        ]

        let result = encoder.encode(
            dataCodewords,
            errorCorrectionCodewordCount: 10
        )

        #expect(
            result == [
                196, 35, 39, 119, 235,
                215, 231, 226, 93, 23
            ]
        )
    }
}
