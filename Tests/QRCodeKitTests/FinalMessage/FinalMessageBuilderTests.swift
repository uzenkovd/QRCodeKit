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
    // MARK: - makeGroups(from:layout:)

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
}
