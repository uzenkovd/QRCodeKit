//
//  KanjiEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct KanjiEncoderTests {
    // MARK: - canEncode(_:)

    @Test
    func canEncodeSupportedShiftJISCharacters() {
        #expect(KanjiEncoder.canEncode("漢あア紂"))
    }

    @Test
    func cannotEncodeEmptyMessage() {
        #expect(!KanjiEncoder.canEncode(""))
    }

    @Test(arguments: [
        "A",
        "ｱ",
        "ｶ",
        "ﾝ"
    ])
    func cannotEncodeSingleByteShiftJISCharacter(
        character: String
    ) {
        #expect(!KanjiEncoder.canEncode(character))
    }

    @Test(arguments: [
        "ї",
        "é",
        "€",
        "🙂",
        "𠮷"
    ])
    func cannotEncodeUnsupportedUnicodeCharacter(
        character: String
    ) {
        #expect(!KanjiEncoder.canEncode(character))
    }

    // MARK: - characterCount(for:)

    @Test
    func characterCountMatchesCharacterCount() {
        let count = KanjiEncoder.characterCount(
            for: "日本語"
        )

        #expect(count == 3)
    }

    // MARK: - encode(_:)

    @Test
    func encodeSingleCharacter() {
        let result = KanjiEncoder.encode("漢")

        #expect(result.count == 13)
        #expect(result.bytes == [
            0b00111001,
            0b11111000
        ])
    }

    @Test
    func encodeLowerBoundaryOfFirstRange() {
        let result = KanjiEncoder.encode("\u{3000}") // Shift JIS: 0x8140

        #expect(result.count == 13)
        #expect(result.bytes == [
            0b00000000,
            0b00000000
        ])
    }

    @Test
    func encodeUpperBoundaryOfFirstRange() {
        let result = KanjiEncoder.encode("滌") // Shift JIS: 0x9FFC

        #expect(result.count == 13)
        #expect(result.bytes == [
            0b10111001,
            0b11100000
        ])
    }

    @Test
    func encodeLowerBoundaryOfSecondRange() {
        let result = KanjiEncoder.encode("漾") // Shift JIS: 0xE040

        #expect(result.count == 13)
        #expect(result.bytes == [
            0b10111010,
            0b00000000
        ])
    }

    @Test
    func encodeCharactersFromBothRanges() {
        let result = KanjiEncoder.encode("海紂")

        #expect(result.count == 26)
        #expect(result.bytes == [
            0b00110110,
            0b00011110,
            0b01100000,
            0b00000000
        ])
    }

    @Test
    func encodeMultipleCharacters() {
        let result = KanjiEncoder.encode("日本語")

        #expect(result.count == 39)
        #expect(result.bytes == [
            0b01110001,
            0b11010011,
            0b11111110,
            0b11010001,
            0b11010100
        ])
    }
}
