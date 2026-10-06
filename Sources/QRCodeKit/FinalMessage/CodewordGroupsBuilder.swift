//
//  CodewordGroupsBuilder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.09.2026.
//

enum CodewordGroupsBuilder {
    static func build(
        from dataCodewords: [UInt8],
        layout: ErrorCorrectionLayout
    ) -> CodewordGroups {
        precondition(
            dataCodewords.count == layout.totalDataCodewordCount,
            "Data codeword count does not match the error correction layout"
        )

        let encoder = ReedSolomonEncoder(
            errorCorrectionCodewordCount:
                layout.errorCorrectionCodewordCountPerBlock
        )

        let group1Info = layout.group1Info
        let group1DataCodewordCount =
            group1Info.totalDataCodewordCount
        let group1DataCodewords = dataCodewords.prefix(
            group1DataCodewordCount
        )

        let group1 = makeGroup(
            from: group1DataCodewords,
            groupInfo: group1Info,
            encoder: encoder
        )

        let group2: Group?

        if let group2Info = layout.group2Info {
            let group2DataCodewords = dataCodewords.dropFirst(
                group1DataCodewordCount
            )

            group2 = makeGroup(
                from: group2DataCodewords,
                groupInfo: group2Info,
                encoder: encoder
            )
        } else {
            group2 = nil
        }

        let groups = CodewordGroups(
            group1: group1,
            group2: group2
        )

        assert(
            groups.totalCodewordCount == layout.totalCodewordCount,
            "Codeword groups do not match the expected error correction layout"
        )

        return groups
    }
}

// MARK: - Group Construction

private extension CodewordGroupsBuilder {
    static func makeGroup(
        from dataCodewords: ArraySlice<UInt8>,
        groupInfo: GroupInfo,
        encoder: ReedSolomonEncoder
    ) -> Group {
        precondition(
            dataCodewords.count == groupInfo.totalDataCodewordCount,
            "Group data codeword count does not match the expected layout"
        )

        var blocks: [Block] = []
        blocks.reserveCapacity(groupInfo.blockCount)

        var currentIndex = dataCodewords.startIndex

        for _ in 0..<groupInfo.blockCount {
            let endIndex = dataCodewords.index(
                currentIndex,
                offsetBy: groupInfo.dataCodewordCountPerBlock
            )

            let blockDataCodewords = Array(
                dataCodewords[currentIndex..<endIndex]
            )

            let blockErrorCorrectionCodewords = encoder.encode(
                blockDataCodewords
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
