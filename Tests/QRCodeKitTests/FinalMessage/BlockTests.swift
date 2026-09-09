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
    func propertiesForCodewords() {
        let dataCodewords: [UInt8] = [1, 2, 3, 4]
        let errorCorrectionCodewords: [UInt8] = [5, 6, 7]

        let block = Block(
            dataCodewords: dataCodewords,
            errorCorrectionCodewords: errorCorrectionCodewords
        )

        #expect(block.dataCodewords == dataCodewords)
        #expect(block.errorCorrectionCodewords == errorCorrectionCodewords)
        #expect(block.codewords == [1, 2, 3, 4, 5, 6, 7])
        #expect(block.dataCodewordCount == 4)
        #expect(block.errorCorrectionCodewordCount == 3)
        #expect(block.codewordCount == 7)
    }

    @Test
    func equalityUsesCodewords() {
        let block = Block(
            dataCodewords: [1, 2, 3, 4],
            errorCorrectionCodewords: [5, 6, 7]
        )
        let equalBlock = Block(
            dataCodewords: [1, 2, 3, 4],
            errorCorrectionCodewords: [5, 6, 7]
        )
        let differentDataBlock = Block(
            dataCodewords: [1, 2, 3, 8],
            errorCorrectionCodewords: [5, 6, 7]
        )
        let differentErrorCorrectionBlock = Block(
            dataCodewords: [1, 2, 3, 4],
            errorCorrectionCodewords: [5, 6, 8]
        )

        #expect(block == equalBlock)
        #expect(block != differentDataBlock)
        #expect(block != differentErrorCorrectionBlock)
    }
}
