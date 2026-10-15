//
//  GroupTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct GroupTests {
    @Test
    func propertiesForSingleBlockGroup() {
        let block = Block(
            dataCodewords: [1, 2, 3, 4],
            errorCorrectionCodewords: [5, 6, 7]
        )

        let group = Group(blocks: [block])

        #expect(group.blocks == [block])
        #expect(group.dataCodewords == [1, 2, 3, 4])
        #expect(group.errorCorrectionCodewords == [5, 6, 7])
        #expect(group.blockCount == 1)
        #expect(group.dataCodewordCountPerBlock == 4)
        #expect(group.errorCorrectionCodewordCountPerBlock == 3)
        #expect(group.totalDataCodewordCount == 4)
        #expect(group.totalErrorCorrectionCodewordCount == 3)
        #expect(group.totalCodewordCount == 7)
    }

    @Test
    func propertiesForMultipleBlocksGroup() {
        let blocks = [
            Block(
                dataCodewords: [1, 2, 3, 4],
                errorCorrectionCodewords: [13, 14, 15]
            ),
            Block(
                dataCodewords: [5, 6, 7, 8],
                errorCorrectionCodewords: [16, 17, 18]
            ),
            Block(
                dataCodewords: [9, 10, 11, 12],
                errorCorrectionCodewords: [19, 20, 21]
            )
        ]

        let group = Group(blocks: blocks)

        #expect(group.blocks == blocks)
        #expect(
            group.dataCodewords
                == [
                    1, 2, 3, 4,
                    5, 6, 7, 8,
                    9, 10, 11, 12
                ]
        )
        #expect(
            group.errorCorrectionCodewords
                == [
                    13, 14, 15,
                    16, 17, 18,
                    19, 20, 21
                ]
        )
        #expect(group.blockCount == 3)
        #expect(group.dataCodewordCountPerBlock == 4)
        #expect(group.errorCorrectionCodewordCountPerBlock == 3)
        #expect(group.totalDataCodewordCount == 12)
        #expect(group.totalErrorCorrectionCodewordCount == 9)
        #expect(group.totalCodewordCount == 21)
    }

    @Test
    func equalityUsesBlocks() {
        let firstBlock = Block(
            dataCodewords: [1, 2, 3, 4],
            errorCorrectionCodewords: [9, 10, 11]
        )
        let secondBlock = Block(
            dataCodewords: [5, 6, 7, 8],
            errorCorrectionCodewords: [12, 13, 14]
        )
        let differentBlock = Block(
            dataCodewords: [5, 6, 7, 9],
            errorCorrectionCodewords: [12, 13, 14]
        )

        let group = Group(blocks: [firstBlock, secondBlock])
        let equalGroup = Group(blocks: [firstBlock, secondBlock])
        let differentGroup = Group(blocks: [firstBlock, differentBlock])

        #expect(group == equalGroup)
        #expect(group != differentGroup)
    }
}
