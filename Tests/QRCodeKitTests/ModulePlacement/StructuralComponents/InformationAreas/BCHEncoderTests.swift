//
//  BCHEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 25.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct BCHEncoderTests {
    @Test
    func zeroDataProducesZeroCodeword() {
        let codeword = BCHEncoder.encode(
            0,
            generator: 0x537,
            remainderBitCount: 10
        )

        #expect(codeword == 0)
    }

    @Test(arguments: [
        (1, 0x0537),
        (8, 0x23D6),
        (31, 0x7FFF)
    ])
    func encodeWithFormatInformationGenerator(
        data: UInt32,
        expectedCodeword: UInt32
    ) {
        let codeword = BCHEncoder.encode(
            data,
            generator: 0x537,
            remainderBitCount: 10
        )

        #expect(codeword == expectedCodeword)
    }

    @Test(arguments: [
        (7, 0x07C94),
        (8, 0x085BC),
        (40, 0x28C69)
    ])
    func encodeWithVersionInformationGenerator(
        data: UInt32,
        expectedCodeword: UInt32
    ) {
        let codeword = BCHEncoder.encode(
            data,
            generator: 0x1F25,
            remainderBitCount: 12
        )

        #expect(codeword == expectedCodeword)
    }
}
