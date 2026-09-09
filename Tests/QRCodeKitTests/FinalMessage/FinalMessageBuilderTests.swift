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
    // MARK: - Group Construction

    @Test
    func makeCodewordGroupsWithSingleGroup() {
        let block1DataCodewords = [UInt8](repeating: 1, count: 17)
        let block2DataCodewords = [UInt8](repeating: 2, count: 17)

        let dataCodewords =
            block1DataCodewords
            + block2DataCodewords

        let groups = FinalMessageBuilder.makeCodewordGroups(
            from: dataCodewords,
            version: .v3,
            errorCorrectionLevel: .Q
        )

        let expectedGroup1 = Group(
            blocks: [
                Block(
                    dataCodewords: block1DataCodewords,
                    errorCorrectionCodewords: [
                        127, 161, 234, 156, 78, 202,
                        159, 227, 139, 96, 44, 133,
                        157, 213, 19, 248, 1, 177
                    ]
                ),
                Block(
                    dataCodewords: block2DataCodewords,
                    errorCorrectionCodewords: [
                        254, 95, 201, 37, 156, 137,
                        35, 219, 11, 192, 88, 23,
                        39, 183, 38, 237, 2, 127
                    ]
                )
            ]
        )

        #expect(groups.group1 == expectedGroup1)
        #expect(groups.group2 == nil)
    }

    @Test
    func makeCodewordGroupsWithTwoGroups() {
        let group1Block1DataCodewords = [UInt8](repeating: 1, count: 15)
        let group1Block2DataCodewords = [UInt8](repeating: 2, count: 15)
        let group2Block1DataCodewords = [UInt8](repeating: 3, count: 16)
        let group2Block2DataCodewords = [UInt8](repeating: 4, count: 16)

        let dataCodewords =
            group1Block1DataCodewords
            + group1Block2DataCodewords
            + group2Block1DataCodewords
            + group2Block2DataCodewords

        let groups = FinalMessageBuilder.makeCodewordGroups(
            from: dataCodewords,
            version: .v5,
            errorCorrectionLevel: .Q
        )

        let expectedGroup1 = Group(
            blocks: [
                Block(
                    dataCodewords: group1Block1DataCodewords,
                    errorCorrectionCodewords: [
                        25, 217, 173, 177, 165, 233,
                        144, 48, 146, 3, 169, 205,
                        25, 97, 12, 115, 108, 175
                    ]
                ),
                Block(
                    dataCodewords: group1Block2DataCodewords,
                    errorCorrectionCodewords: [
                        50, 175, 71, 127, 87, 207,
                        61, 96, 57, 6, 79, 135,
                        50, 194, 24, 230, 216, 67
                    ]
                )
            ]
        )

        let expectedGroup2 = Group(
            blocks: [
                Block(
                    dataCodewords: group2Block1DataCodewords,
                    errorCorrectionCodewords: [
                        241, 119, 124, 219, 173, 248,
                        227, 162, 189, 202, 237, 19,
                        166, 227, 252, 30, 72, 83
                    ]
                ),
                Block(
                    dataCodewords: group2Block2DataCodewords,
                    errorCorrectionCodewords: [
                        170, 180, 91, 57, 122, 182,
                        146, 110, 177, 5, 113, 207,
                        149, 146, 77, 40, 224, 196
                    ]
                )
            ]
        )

        #expect(groups.group1 == expectedGroup1)
        #expect(groups.group2 == expectedGroup2)
    }

    // MARK: - Codeword Interleaving

    @Test
    func interleaveCodewordsWithSingleBlockGroup() {
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

        let interleavedCodewords = FinalMessageBuilder.interleaveCodewords(
            from: groups
        )

        #expect(interleavedCodewords.dataCodewords == [1, 2, 3])
        #expect(interleavedCodewords.errorCorrectionCodewords == [4, 5])
    }

    @Test
    func interleaveCodewordsWithMultipleBlocksGroup() {
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

        let interleavedCodewords = FinalMessageBuilder.interleaveCodewords(
            from: groups
        )

        #expect(interleavedCodewords.dataCodewords == [1, 2, 3, 4, 5, 6])
        #expect(interleavedCodewords.errorCorrectionCodewords == [7, 8, 9, 10])
    }

    @Test
    func interleaveCodewordsWithTwoGroups() {
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

        let interleavedCodewords = FinalMessageBuilder.interleaveCodewords(
            from: groups
        )

        #expect(
            interleavedCodewords.dataCodewords
                == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        )
        #expect(
            interleavedCodewords.errorCorrectionCodewords
                == [11, 12, 13, 14, 15, 16, 17, 18]
        )
    }
}
