//
//  Group.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.09.2026.
//

struct Group: Equatable {
    let blocks: [Block]

    var dataCodewords: [UInt8] {
        blocks.flatMap(\.dataCodewords)
    }

    var errorCorrectionCodewords: [UInt8] {
        blocks.flatMap(\.errorCorrectionCodewords)
    }

    var blockCount: Int {
        blocks.count
    }

    var dataCodewordCountPerBlock: Int {
        blocks[0].dataCodewordCount
    }

    var errorCorrectionCodewordCountPerBlock: Int {
        blocks[0].errorCorrectionCodewordCount
    }

    var totalDataCodewordCount: Int {
        blockCount * dataCodewordCountPerBlock
    }

    var totalErrorCorrectionCodewordCount: Int {
        blockCount * errorCorrectionCodewordCountPerBlock
    }

    var totalCodewordCount: Int {
        totalDataCodewordCount + totalErrorCorrectionCodewordCount
    }

    init(blocks: [Block]) {
        precondition(
            !blocks.isEmpty,
            "Group blocks must not be empty"
        )

        let firstBlock = blocks[0]
        let remainingBlocks = blocks.dropFirst()

        precondition(
            remainingBlocks.allSatisfy {
                $0.dataCodewordCount == firstBlock.dataCodewordCount
            },
            "Group blocks must have the same data codeword count"
        )
        precondition(
            remainingBlocks.allSatisfy {
                $0.errorCorrectionCodewordCount
                    == firstBlock.errorCorrectionCodewordCount
            },
            "Group blocks must have the same error correction codeword count"
        )

        self.blocks = blocks
    }
}
