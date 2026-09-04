//
//  Group.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.09.2026.
//

struct Group: Equatable {
    let blocks: [Block]

    var blockCount: Int {
        blocks.count
    }

    var dataCodewordCountPerBlock: Int {
        blocks[0].dataCodewordCount
    }

    var errorCorrectionCodewordCountPerBlock: Int {
        blocks[0].errorCorrectionCodewordCount
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
