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
            dataCodewords: [32, 91, 11, 120],
            errorCorrectionCodewords: [196, 35, 39]
        )

        let group = Group(blocks: [block])

        #expect(group.blocks == [block])
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
                dataCodewords: [32, 91, 11, 120],
                errorCorrectionCodewords: [196, 35, 39]
            ),
            Block(
                dataCodewords: [209, 114, 220, 77],
                errorCorrectionCodewords: [119, 235, 215]
            ),
            Block(
                dataCodewords: [67, 64, 236, 17],
                errorCorrectionCodewords: [231, 226, 93]
            )
        ]

        let group = Group(blocks: blocks)

        #expect(group.blocks == blocks)
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
            dataCodewords: [32, 91, 11, 120],
            errorCorrectionCodewords: [196, 35, 39]
        )
        let secondBlock = Block(
            dataCodewords: [209, 114, 220, 77],
            errorCorrectionCodewords: [119, 235, 215]
        )
        let differentBlock = Block(
            dataCodewords: [209, 114, 220, 78],
            errorCorrectionCodewords: [119, 235, 215]
        )

        let group = Group(blocks: [firstBlock, secondBlock])
        let equalGroup = Group(blocks: [firstBlock, secondBlock])
        let differentGroup = Group(blocks: [firstBlock, differentBlock])

        #expect(group == equalGroup)
        #expect(group != differentGroup)
    }
}
