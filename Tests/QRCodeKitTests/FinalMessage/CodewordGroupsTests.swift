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
                    errorCorrectionCodewords: [4, 5]
                ),
                Block(
                    dataCodewords: [6, 7, 8],
                    errorCorrectionCodewords: [9, 10]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: nil
        )

        #expect(groups.blockCount == 2)
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
                    errorCorrectionCodewords: [3, 4]
                ),
                Block(
                    dataCodewords: [5, 6],
                    errorCorrectionCodewords: [7, 8]
                )
            ]
        )

        let group2 = Group(
            blocks: [
                Block(
                    dataCodewords: [9, 10, 11],
                    errorCorrectionCodewords: [12, 13]
                ),
                Block(
                    dataCodewords: [14, 15, 16],
                    errorCorrectionCodewords: [17, 18]
                )
            ]
        )

        let groups = CodewordGroups(
            group1: group1,
            group2: group2
        )

        #expect(groups.blockCount == 4)
        #expect(groups.totalDataCodewordCount == 10)
        #expect(groups.totalErrorCorrectionCodewordCount == 8)
        #expect(groups.totalCodewordCount == 18)
    }
}
