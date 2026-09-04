//
//  BlockTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct BlockTests {
    @Test
    func propertiesForKnownCodewords() {
        let dataCodewords: [UInt8] = [32, 91, 11, 120]
        let errorCorrectionCodewords: [UInt8] = [196, 35, 39]

        let block = Block(
            dataCodewords: dataCodewords,
            errorCorrectionCodewords: errorCorrectionCodewords
        )

        #expect(block.dataCodewords == dataCodewords)
        #expect(block.errorCorrectionCodewords == errorCorrectionCodewords)
        #expect(block.dataCodewordCount == dataCodewords.count)
        #expect(block.errorCorrectionCodewordCount == errorCorrectionCodewords.count)
    }

    @Test
    func equalityUsesCodewords() {
        let block = Block(
            dataCodewords: [32, 91, 11, 120],
            errorCorrectionCodewords: [196, 35, 39]
        )
        let equalBlock = Block(
            dataCodewords: [32, 91, 11, 120],
            errorCorrectionCodewords: [196, 35, 39]
        )
        let differentDataBlock = Block(
            dataCodewords: [32, 91, 11, 121],
            errorCorrectionCodewords: [196, 35, 39]
        )
        let differentErrorCorrectionBlock = Block(
            dataCodewords: [32, 91, 11, 120],
            errorCorrectionCodewords: [196, 35, 40]
        )

        #expect(block == equalBlock)
        #expect(block != differentDataBlock)
        #expect(block != differentErrorCorrectionBlock)
    }
}
