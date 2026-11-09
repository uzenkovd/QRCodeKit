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
    @Test(arguments: QRVersion.allCases.filter { (.v1 ... .v9).contains($0) })
    func matchesSpecificationForVersions1Through9(
        version: QRVersion
    ) {
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .numeric) == 10)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .alphanumeric) == 9)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .byte) == 8)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .kanji) == 8)
    }

    @Test(arguments: QRVersion.allCases.filter { (.v10 ... .v26).contains($0) })
    func matchesSpecificationForVersions10Through26(
        version: QRVersion
    ) {
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .numeric) == 12)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .alphanumeric) == 11)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .byte) == 16)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .kanji) == 10)
    }

    @Test(arguments: QRVersion.allCases.filter { (.v27 ... .v40).contains($0) })
    func matchesSpecificationForVersions27Through40(
        version: QRVersion
    ) {
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .numeric) == 14)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .alphanumeric) == 13)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .byte) == 16)
        #expect(CharacterCountIndicator.bitCount(for: version, mode: .kanji) == 12)
    }
}
