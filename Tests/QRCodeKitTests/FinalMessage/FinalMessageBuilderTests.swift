//
//  FinalMessageBuilderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 06.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct FinalMessageBuilderTests {
    // MARK: - Final Message Building

    @Test
    func buildFromSingleGroupWithoutRemainderBits() {
        let dataCodewords = (1...19).map { UInt8($0) }
        let errorCorrectionCodewords = (20...26).map { UInt8($0) }

        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: dataCodewords,
                    errorCorrectionCodewords: errorCorrectionCodewords
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: nil
        )

        let expectedCodewords = (1...26).map { UInt8($0) }

        let finalBits = FinalMessageBuilder.build(
            from: groups,
            version: .v1
        )

        #expect(finalBits.bytes == expectedCodewords)
        #expect(finalBits.count == 26 * 8 + 0)
    }

    @Test
    func buildFromTwoGroupsWithRemainderBits() {
        let group1Block1DataCodewords =
            stride(from: 1, through: 57, by: 4).map { UInt8($0) }
        let group1Block2DataCodewords =
            stride(from: 2, through: 58, by: 4).map { UInt8($0) }
        let group2Block1DataCodewords =
            stride(from: 3, through: 59, by: 4).map { UInt8($0) }
            + [61]
        let group2Block2DataCodewords =
            stride(from: 4, through: 60, by: 4).map { UInt8($0) }
            + [62]

        let group1Block1ECCodewords =
            stride(from: 63, through: 131, by: 4).map { UInt8($0) }
        let group1Block2ECCodewords =
            stride(from: 64, through: 132, by: 4).map { UInt8($0) }
        let group2Block1ECCodewords =
            stride(from: 65, through: 133, by: 4).map { UInt8($0) }
        let group2Block2ECCodewords =
            stride(from: 66, through: 134, by: 4).map { UInt8($0) }

        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: group1Block1DataCodewords,
                    errorCorrectionCodewords: group1Block1ECCodewords
                ),
                Block(
                    dataCodewords: group1Block2DataCodewords,
                    errorCorrectionCodewords: group1Block2ECCodewords
                )
            ]
        )

        let group2 = Group(
            blocks: [
                Block(
                    dataCodewords: group2Block1DataCodewords,
                    errorCorrectionCodewords: group2Block1ECCodewords
                ),
                Block(
                    dataCodewords: group2Block2DataCodewords,
                    errorCorrectionCodewords: group2Block2ECCodewords
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: group2
        )

        let expectedCodewords = (1...134).map { UInt8($0) }

        let finalBits = FinalMessageBuilder.build(
            from: groups,
            version: .v5
        )

        #expect(finalBits.bytes == expectedCodewords + [0])
        #expect(finalBits.count == 134 * 8 + 7)
    }

    // MARK: - Codeword Interleaving

    @Test
    func interleaveCodewordsInSingleBlockGroup() {
        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 2, 3],
                    errorCorrectionCodewords: [4, 5]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: nil
        )

        let interleaved = FinalMessageBuilder.interleaveCodewords(
            from: groups
        )

        #expect(interleaved.dataCodewords == [1, 2, 3])
        #expect(interleaved.errorCorrectionCodewords == [4, 5])
    }

    @Test
    func interleaveCodewordsInMultipleBlockGroup() {
        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 3, 5],
                    errorCorrectionCodewords: [7, 9]
                ),
                Block(
                    dataCodewords: [2, 4, 6],
                    errorCorrectionCodewords: [8, 10]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: nil
        )

        let interleaved = FinalMessageBuilder.interleaveCodewords(
            from: groups
        )

        #expect(interleaved.dataCodewords == [1, 2, 3, 4, 5, 6])
        #expect(interleaved.errorCorrectionCodewords == [7, 8, 9, 10])
    }

    @Test
    func interleaveCodewordsInTwoGroups() {
        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 5],
                    errorCorrectionCodewords: [11, 15]
                ),
                Block(
                    dataCodewords: [2, 6],
                    errorCorrectionCodewords: [12, 16]
                )
            ]
        )

        let group2 = Group(
            blocks: [
                Block(
                    dataCodewords: [3, 7, 9],
                    errorCorrectionCodewords: [13, 17]
                ),
                Block(
                    dataCodewords: [4, 8, 10],
                    errorCorrectionCodewords: [14, 18]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: group2
        )

        let interleaved = FinalMessageBuilder.interleaveCodewords(
            from: groups
        )

        #expect(
            interleaved.dataCodewords
                == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        )
        #expect(
            interleaved.errorCorrectionCodewords
                == [11, 12, 13, 14, 15, 16, 17, 18]
        )
    }
}
