//
//  CodewordGroupsTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct CodewordGroupsTests {
    @Test
    func propertiesForSingleGroup() {
        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 2, 3],
                    errorCorrectionCodewords: [7, 8]
                ),
                Block(
                    dataCodewords: [4, 5, 6],
                    errorCorrectionCodewords: [9, 10]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: nil
        )

        #expect(groups.blocks == group1.blocks)
        #expect(groups.dataCodewords == [1, 2, 3, 4, 5, 6])
        #expect(groups.errorCorrectionCodewords == [7, 8, 9, 10])
        #expect(groups.totalBlockCount == 2)
        #expect(groups.totalDataCodewordCount == 6)
        #expect(groups.totalErrorCorrectionCodewordCount == 4)
        #expect(groups.totalCodewordCount == 10)
    }

    @Test
    func propertiesForTwoGroups() {
        let group1 = Group(
            blocks: [
                Block(
                    dataCodewords: [1, 2],
                    errorCorrectionCodewords: [11, 12]
                ),
                Block(
                    dataCodewords: [3, 4],
                    errorCorrectionCodewords: [13, 14]
                )
            ]
        )

        let group2 = Group(
            blocks: [
                Block(
                    dataCodewords: [5, 6, 7],
                    errorCorrectionCodewords: [15, 16]
                ),
                Block(
                    dataCodewords: [8, 9, 10],
                    errorCorrectionCodewords: [17, 18]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: group2
        )

        #expect(groups.blocks == group1.blocks + group2.blocks)
        #expect(
            groups.dataCodewords
                == [
                    1, 2,
                    3, 4,
                    5, 6, 7,
                    8, 9, 10
                ]
        )
        #expect(
            groups.errorCorrectionCodewords
                == [
                    11, 12,
                    13, 14,
                    15, 16,
                    17, 18
                ]
        )
        #expect(groups.totalBlockCount == 4)
        #expect(groups.totalDataCodewordCount == 10)
        #expect(groups.totalErrorCorrectionCodewordCount == 8)
        #expect(groups.totalCodewordCount == 18)
    }
}
