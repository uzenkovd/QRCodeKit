//
//  FinalMessageBuilder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 05.09.2026.
//

struct FinalMessageBuilder {
    static func makeGroups(
        from dataCodewords: [UInt8],
        layout: ErrorCorrectionLayout
    ) -> (group1: Group, group2: Group?) {
        precondition(
            dataCodewords.count == layout.totalDataCodewordCount,
            "Data codeword count does not match the error correction layout"
        )

        let group1DataCodewordCount =
            layout.group1.totalDataCodewordCount
        let group1DataCodewords = dataCodewords.prefix(
            group1DataCodewordCount
        )
        let group1 = Self.makeGroup(
            from: group1DataCodewords,
            info: layout.group1,
            errorCorrectionCodewordCountPerBlock:
                layout.errorCorrectionCodewordCountPerBlock
        )

        guard let group2Info = layout.group2 else {
            return (group1, nil)
        }

        let group2DataCodewords = dataCodewords.dropFirst(
            group1DataCodewordCount
        )
        let group2 = Self.makeGroup(
            from: group2DataCodewords,
            info: group2Info,
            errorCorrectionCodewordCountPerBlock:
                layout.errorCorrectionCodewordCountPerBlock
        )

        return (group1, group2)
    }

    private static func makeGroup(
        from dataCodewords: ArraySlice<UInt8>,
        info: GroupInfo,
        errorCorrectionCodewordCountPerBlock: Int
    ) -> Group {
        precondition(
            dataCodewords.count == info.totalDataCodewordCount,
            "Group data codeword count does not match the expected layout"
        )

        var blocks: [Block] = []
        blocks.reserveCapacity(info.blockCount)

        let encoder = ReedSolomonEncoder()
        var currentIndex = dataCodewords.startIndex

        for _ in 0..<info.blockCount {
            let endIndex = dataCodewords.index(
                currentIndex,
                offsetBy: info.dataCodewordCountPerBlock
            )

            let blockDataCodewords = Array(
                dataCodewords[currentIndex..<endIndex]
            )

            let blockErrorCorrectionCodewords = encoder.encode(
                blockDataCodewords,
                errorCorrectionCodewordCount: errorCorrectionCodewordCountPerBlock
            )

            let block = Block(
                dataCodewords: blockDataCodewords,
                errorCorrectionCodewords: blockErrorCorrectionCodewords
            )

            blocks.append(block)
            currentIndex = endIndex
        }

        assert(
            currentIndex == dataCodewords.endIndex,
            "Group construction did not consume all data codewords"
        )

        return Group(blocks: blocks)
    }
}
