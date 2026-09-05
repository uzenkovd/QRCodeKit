//
//  ErrorCorrectionBlocksTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 24.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct ErrorCorrectionBlocksTests {

    // MARK: - GroupInfo

    @Test
    func groupInfoProperties() {
        let group = GroupInfo(3, 15)

        #expect(group.blockCount == 3)
        #expect(group.dataCodewordCountPerBlock == 15)
        #expect(group.totalDataCodewordCount == 45)
    }

    // MARK: - ErrorCorrectionLayout

    @Test
    func errorCorrectionLayoutWithOneGroup() {
        let layout = ErrorCorrectionLayout(
            7,
            GroupInfo(1, 19)
        )

        #expect(layout.errorCorrectionCodewordCountPerBlock == 7)
        #expect(layout.group1.blockCount == 1)
        #expect(layout.group1.dataCodewordCountPerBlock == 19)
        #expect(layout.group2 == nil)
        #expect(layout.totalBlockCount == 1)
        #expect(layout.totalDataCodewordCount == 19)
        #expect(layout.totalErrorCorrectionCodewordCount == 7)
        #expect(layout.totalCodewordCount == 26)
    }

    @Test
    func errorCorrectionLayoutWithTwoGroups() {
        let layout = ErrorCorrectionLayout(
            18,
            GroupInfo(2, 15),
            GroupInfo(2, 16)
        )

        #expect(layout.errorCorrectionCodewordCountPerBlock == 18)
        #expect(layout.group1.blockCount == 2)
        #expect(layout.group1.dataCodewordCountPerBlock == 15)
        #expect(layout.group2?.blockCount == 2)
        #expect(layout.group2?.dataCodewordCountPerBlock == 16)
        #expect(layout.totalBlockCount == 4)
        #expect(layout.totalDataCodewordCount == 62)
        #expect(layout.totalErrorCorrectionCodewordCount == 72)
        #expect(layout.totalCodewordCount == 134)
    }

    // MARK: - totalDataCodewordCount(for:level:)

    @Test
    func totalDataCodewordCountForVersion1Low() {
        let totalDataCodewords = ErrorCorrectionBlocks.totalDataCodewordCount(
            for: .v1,
            level: .L
        )

        #expect(totalDataCodewords == 19)
    }

    @Test
    func totalDataCodewordCountForVersion29Quartile() {
        let totalDataCodewords = ErrorCorrectionBlocks.totalDataCodewordCount(
            for: .v29,
            level: .Q
        )

        #expect(totalDataCodewords == 911)
    }

    // MARK: - layout(for:level:)

    @Test
    func layoutForVersion1Low() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v1,
            level: .L
        )

        #expect(layout.errorCorrectionCodewordCountPerBlock == 7)
        #expect(layout.group1.blockCount == 1)
        #expect(layout.group1.dataCodewordCountPerBlock == 19)
        #expect(layout.group2 == nil)
    }

    @Test
    func layoutForVersion22Medium() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v22,
            level: .M
        )

        #expect(layout.errorCorrectionCodewordCountPerBlock == 28)
        #expect(layout.group1.blockCount == 17)
        #expect(layout.group1.dataCodewordCountPerBlock == 46)
        #expect(layout.group2 == nil)
    }

    @Test
    func layoutForVersion29Quartile() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v29,
            level: .Q
        )

        #expect(layout.errorCorrectionCodewordCountPerBlock == 30)
        #expect(layout.group1.blockCount == 1)
        #expect(layout.group1.dataCodewordCountPerBlock == 23)
        #expect(layout.group2?.blockCount == 37)
        #expect(layout.group2?.dataCodewordCountPerBlock == 24)
    }

    @Test
    func layoutForVersion40High() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v40,
            level: .H
        )

        #expect(layout.errorCorrectionCodewordCountPerBlock == 30)
        #expect(layout.group1.blockCount == 20)
        #expect(layout.group1.dataCodewordCountPerBlock == 15)
        #expect(layout.group2?.blockCount == 61)
        #expect(layout.group2?.dataCodewordCountPerBlock == 16)
    }

    @Test
    func totalCodewordCountIsEqualForAllLevelsOfEachVersion() {
        for version in QRVersion.allCases {
            let totals = ErrorCorrectionLevel.allCases.map { level in
                ErrorCorrectionBlocks
                    .layout(for: version, level: level)
                    .totalCodewordCount
            }

            #expect(Set(totals).count == 1)
        }
    }
}
