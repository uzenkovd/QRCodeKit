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
    func makeGroupsWithOneGroup() {
        let dataCodewords: [UInt8] = [1, 2, 3, 4]
        let layout = ErrorCorrectionLayout(
            2,
            GroupInfo(2, 2)
        )

        let groups = FinalMessageBuilder.makeGroups(
            from: dataCodewords,
            layout: layout
        )

        let expectedGroup1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 2],
                    errorCorrectionCodewords: [1, 2]
                ),
                Block(
                    dataCodewords: [3, 4],
                    errorCorrectionCodewords: [5, 2]
                )
            ]
        )

        #expect(groups.group1 == expectedGroup1)
        #expect(groups.group2 == nil)
    }

    @Test
    func makeGroupsWithTwoGroups() {
        let dataCodewords: [UInt8] = [
            1, 2, 3, 4, 5, 6, 7, 8
        ]

        let layout = ErrorCorrectionLayout(
            2,
            GroupInfo(1, 2),
            GroupInfo(2, 3)
        )

        let groups = FinalMessageBuilder.makeGroups(
            from: dataCodewords,
            layout: layout
        )

        let expectedGroup1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 2],
                    errorCorrectionCodewords: [1, 2]
                )
            ]
        )

        let expectedGroup2 = Group(
            blocks: [
                Block(
                    dataCodewords: [3, 4, 5],
                    errorCorrectionCodewords: [2, 0]
                ),
                Block(
                    dataCodewords: [6, 7, 8],
                    errorCorrectionCodewords: [47, 38]
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

        let interleavedCodewords = FinalMessageBuilder.interleaveCodewords(
            group1: group1,
            group2: nil
        )

        #expect(interleavedCodewords.dataCodewords == [1, 2, 3])
        #expect(interleavedCodewords.errorCorrectionCodewords == [4, 5])
    }

    @Test
    func interleaveCodewordsWithOneGroup() {
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

        let interleavedCodewords = FinalMessageBuilder.interleaveCodewords(
            group1: group1,
            group2: nil
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

        let interleavedCodewords = FinalMessageBuilder.interleaveCodewords(
            group1: group1,
            group2: group2
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
