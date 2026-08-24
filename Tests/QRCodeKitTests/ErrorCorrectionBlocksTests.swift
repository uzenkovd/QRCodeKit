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
    
    // MARK: - Group
    
    @Test
    func groupTotalDataCodewords() {
        let group = ErrorCorrectionBlocks.Group(3, 15)
        
        #expect(group.totalDataCodewords == 45)
    }
    
    // MARK: - Layout
    
    @Test
    func layoutWithoutSecondGroup() {
        let layout = ErrorCorrectionBlocks.Layout(
            7,
            ErrorCorrectionBlocks.Group(1, 19)
        )
        
        #expect(layout.totalBlockCount == 1)
        #expect(layout.totalDataCodewords == 19)
        #expect(layout.totalErrorCorrectionCodewords == 7)
        #expect(layout.totalCodewords == 26)
    }
    
    @Test
    func layoutWithSecondGroup() {
        let layout = ErrorCorrectionBlocks.Layout(
            18,
            ErrorCorrectionBlocks.Group(2, 15),
            ErrorCorrectionBlocks.Group(2, 16)
        )
        
        #expect(layout.totalBlockCount == 4)
        #expect(layout.totalDataCodewords == 62)
        #expect(layout.totalErrorCorrectionCodewords == 72)
        #expect(layout.totalCodewords == 134)
    }
    
    // MARK: - totalDataCodewords(for:level:)
    
    @Test
    func totalDataCodewordsForVersion1Low() {
        let totalDataCodewords = ErrorCorrectionBlocks.totalDataCodewords(
            for: .v1,
            level: .L
        )
        
        #expect(totalDataCodewords == 19)
    }
    
    @Test
    func totalDataCodewordsForVersion29Quartile() {
        let totalDataCodewords = ErrorCorrectionBlocks.totalDataCodewords(
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
        
        #expect(layout.errorCorrectionCodewordsPerBlock == 7)
        #expect(layout.group1.blockCount == 1)
        #expect(layout.group1.dataCodewordsPerBlock == 19)
        #expect(layout.group2 == nil)
    }
    
    @Test
    func layoutForVersion22Medium() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v22,
            level: .M
        )
        
        #expect(layout.errorCorrectionCodewordsPerBlock == 28)
        #expect(layout.group1.blockCount == 17)
        #expect(layout.group1.dataCodewordsPerBlock == 46)
        #expect(layout.group2 == nil)
    }
    
    @Test
    func layoutForVersion29Quartile() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v29,
            level: .Q
        )
        
        #expect(layout.errorCorrectionCodewordsPerBlock == 30)
        #expect(layout.group1.blockCount == 1)
        #expect(layout.group1.dataCodewordsPerBlock == 23)
        #expect(layout.group2?.blockCount == 37)
        #expect(layout.group2?.dataCodewordsPerBlock == 24)
    }
    
    @Test
    func layoutForVersion40High() {
        let layout = ErrorCorrectionBlocks.layout(
            for: .v40,
            level: .H
        )
        
        #expect(layout.errorCorrectionCodewordsPerBlock == 30)
        #expect(layout.group1.blockCount == 20)
        #expect(layout.group1.dataCodewordsPerBlock == 15)
        #expect(layout.group2?.blockCount == 61)
        #expect(layout.group2?.dataCodewordsPerBlock == 16)
    }
    
    @Test
    func totalCodewordsAreEqualForAllLevelsOfEachVersion() {
        for version in QRVersion.allCases {
            let totals = ErrorCorrectionLevel.allCases.map { level in
                ErrorCorrectionBlocks
                    .layout(for: version, level: level)
                    .totalCodewords
            }
            
            #expect(Set(totals).count == 1)
        }
    }
}
