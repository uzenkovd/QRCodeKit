//
//  CodewordGroupsBuilderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct CodewordGroupsBuilderTests {
    @Test
    func buildWithSingleGroup() {
        let block1DataCodewords = [UInt8](repeating: 1, count: 17)
        let block2DataCodewords = [UInt8](repeating: 2, count: 17)

        let block1ECCodewords: [UInt8] = [
            127, 161, 234, 156, 78, 202,
            159, 227, 139, 96, 44, 133,
            157, 213, 19, 248, 1, 177
        ]
        let block2ECCodewords: [UInt8] = [
            254, 95, 201, 37, 156, 137,
            35, 219, 11, 192, 88, 23,
            39, 183, 38, 237, 2, 127
        ]

        let dataCodewords =
            block1DataCodewords
            + block2DataCodewords

        let layout = ErrorCorrectionBlocks.layout(
            for: .v3,
            level: .Q
        )

        let expectedGroup1 = Group(
            blocks: [
                Block(
                    dataCodewords: block1DataCodewords,
                    errorCorrectionCodewords: block1ECCodewords
                ),
                Block(
                    dataCodewords: block2DataCodewords,
                    errorCorrectionCodewords: block2ECCodewords
                )
            ]
        )

        let groups = CodewordGroupsBuilder.build(
            from: dataCodewords,
            layout: layout
        )

        #expect(groups.group1 == expectedGroup1)
        #expect(groups.group2 == nil)
    }

    @Test
    func buildWithTwoGroups() {
        let group1Block1DataCodewords =
            [UInt8](repeating: 1, count: 15)
        let group1Block2DataCodewords =
            [UInt8](repeating: 2, count: 15)
        let group2Block1DataCodewords =
            [UInt8](repeating: 3, count: 16)
        let group2Block2DataCodewords =
            [UInt8](repeating: 4, count: 16)

        let group1Block1ECCodewords: [UInt8] = [
            25, 217, 173, 177, 165, 233,
            144, 48, 146, 3, 169, 205,
            25, 97, 12, 115, 108, 175
        ]
        let group1Block2ECCodewords: [UInt8] = [
            50, 175, 71, 127, 87, 207,
            61, 96, 57, 6, 79, 135,
            50, 194, 24, 230, 216, 67
        ]
        let group2Block1ECCodewords: [UInt8] = [
            241, 119, 124, 219, 173, 248,
            227, 162, 189, 202, 237, 19,
            166, 227, 252, 30, 72, 83
        ]
        let group2Block2ECCodewords: [UInt8] = [
            170, 180, 91, 57, 122, 182,
            146, 110, 177, 5, 113, 207,
            149, 146, 77, 40, 224, 196
        ]

        let dataCodewords =
            group1Block1DataCodewords
            + group1Block2DataCodewords
            + group2Block1DataCodewords
            + group2Block2DataCodewords

        let layout = ErrorCorrectionBlocks.layout(
            for: .v5,
            level: .Q
        )

        let expectedGroup1 = Group(
            blocks: [
                Block(
                    dataCodewords: group1Block1DataCodewords,
                    errorCorrectionCodewords:
                        group1Block1ECCodewords
                ),
                Block(
                    dataCodewords: group1Block2DataCodewords,
                    errorCorrectionCodewords:
                        group1Block2ECCodewords
                )
            ]
        )

        let expectedGroup2 = Group(
            blocks: [
                Block(
                    dataCodewords: group2Block1DataCodewords,
                    errorCorrectionCodewords:
                        group2Block1ECCodewords
                ),
                Block(
                    dataCodewords: group2Block2DataCodewords,
                    errorCorrectionCodewords:
                        group2Block2ECCodewords
                )
            ]
        )

        let groups = CodewordGroupsBuilder.build(
            from: dataCodewords,
            layout: layout
        )

        #expect(groups.group1 == expectedGroup1)
        #expect(groups.group2 == expectedGroup2)
    }
}
