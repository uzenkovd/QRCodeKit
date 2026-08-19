//
//  CharacterCountIndicatorLengthsTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.08.2026.
//

import Testing
@testable import QRCodeKit

@Test
func allVersionRanges() {
    for version in QRVersion.v1 ... .v9 {
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .numeric) == 10)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .alphanumeric) == 9)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .kanji) == 8)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .byte) == 8)
    }
    
    for version in QRVersion.v10 ... .v26 {
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .numeric) == 12)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .alphanumeric) == 11)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .kanji) == 10)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .byte) == 16)
    }
    
    for version in QRVersion.v27 ... .v40 {
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .numeric) == 14)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .alphanumeric) == 13)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .kanji) == 12)
        #expect(CharacterCountIndicatorLengths.length(for: version, mode: .byte) == 16)
    }
}
