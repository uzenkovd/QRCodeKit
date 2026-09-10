//
//  FinalMessageBuilder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 05.09.2026.
//

struct FinalMessageBuilder {
    // TODO: Validate that codeword groups match the resolved QR configuration
    // once QRConfiguration is introduced
    static func build(
        from groups: CodewordGroups,
        version: QRVersion
    ) -> BitBuffer {
        let interleaved = Self.interleaveCodewords(from: groups)
        let remainderBitCount = RemainderBits.bitCount(for: version)

        var finalBits = BitBuffer()

        finalBits.append(contentsOf: interleaved.dataCodewords)
        finalBits.append(contentsOf: interleaved.errorCorrectionCodewords)
        finalBits.append(0, bitCount: remainderBitCount)

        let expectedBitCount = groups.totalCodewordCount * 8 + remainderBitCount

        assert(
            finalBits.count == expectedBitCount,
            "Final message does not match the expected bit count"
        )

        return finalBits
    }
}

// MARK: - Group Construction

extension FinalMessageBuilder {
    static func makeCodewordGroups(
        from dataCodewords: [UInt8],
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> CodewordGroups {
        let layout = ErrorCorrectionBlocks.layout(
            for: version,
            level: errorCorrectionLevel
        )

        precondition(
            dataCodewords.count == layout.totalDataCodewordCount,
            "Data codeword count does not match the error correction layout"
        )

        let group1Info = layout.group1
        let group1DataCodewordCount =
            group1Info.totalDataCodewordCount
        let group1DataCodewords = dataCodewords.prefix(
            group1DataCodewordCount
        )
        let group1 = Self.makeGroup(
            from: group1DataCodewords,
            info: group1Info,
            errorCorrectionCodewordCountPerBlock:
                layout.errorCorrectionCodewordCountPerBlock
        )

        let group2: Group?

        if let group2Info = layout.group2 {
            let group2DataCodewords = dataCodewords.dropFirst(
                group1DataCodewordCount
            )

            group2 = Self.makeGroup(
                from: group2DataCodewords,
                info: group2Info,
                errorCorrectionCodewordCountPerBlock:
                    layout.errorCorrectionCodewordCountPerBlock
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

// MARK: - Codeword Interleaving

extension FinalMessageBuilder {
    static func interleaveCodewords(
        from groups: CodewordGroups
    ) -> (
        dataCodewords: [UInt8],
        errorCorrectionCodewords: [UInt8]
    ) {
        let blocks = groups.blocks

        let interleavedDataCodewords = Self.interleave(
            blocks,
            codewords: \.dataCodewords
        )

        let interleavedErrorCorrectionCodewords = Self.interleave(
            blocks,
            codewords: \.errorCorrectionCodewords
        )

        return (
            interleavedDataCodewords,
            interleavedErrorCorrectionCodewords
        )
    }

    private static func interleave(
        _ blocks: [Block],
        codewords keyPath: KeyPath<Block, [UInt8]>
    ) -> [UInt8] {
        let codewordCount = blocks.reduce(0) {
            $0 + $1[keyPath: keyPath].count
        }

        var interleavedCodewords: [UInt8] = []
        interleavedCodewords.reserveCapacity(codewordCount)

        let maximumCodewordCountPerBlock = blocks.reduce(0) {
            max($0, $1[keyPath: keyPath].count)
        }

        for codewordIndex in 0..<maximumCodewordCountPerBlock {
            for block in blocks {
                let blockCodewords = block[keyPath: keyPath]

                if codewordIndex < blockCodewords.count {
                    interleavedCodewords.append(
                        blockCodewords[codewordIndex]
                    )
                }
            }
        }

        assert(
            interleavedCodewords.count == codewordCount,
            "Interleaving did not produce the expected codeword count"
        )

        return interleavedCodewords
    }
}
