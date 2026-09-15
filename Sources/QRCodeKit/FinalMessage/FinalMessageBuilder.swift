//
//  FinalMessageBuilder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 05.09.2026.
//

enum FinalMessageBuilder {
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
