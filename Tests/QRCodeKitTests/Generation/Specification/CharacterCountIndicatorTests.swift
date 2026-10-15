//
//  CharacterCountIndicatorTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct CharacterCountIndicatorTests {
    @Test
    func bitCountForAllVersionRanges() {
        for version in QRVersion.v1 ... .v9 {
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .numeric) == 10)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .alphanumeric) == 9)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .byte) == 8)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .kanji) == 8)
        }

        for version in QRVersion.v10 ... .v26 {
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .numeric) == 12)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .alphanumeric) == 11)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .byte) == 16)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .kanji) == 10)
        }

        for version in QRVersion.v27 ... .v40 {
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .numeric) == 14)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .alphanumeric) == 13)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .byte) == 16)
            #expect(CharacterCountIndicator.bitCount(for: version, mode: .kanji) == 12)
        }
    }
}
