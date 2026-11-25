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
    func canEncodeEmptyMessage() {
        #expect(KanjiEncoder.canEncode(""))
    }

    @Test
    func canEncodeDoubleByteShiftJISCharacters() {
        #expect(KanjiEncoder.canEncode("漢あア紂"))
    }

    @Test(arguments: ["A", "ｱ"])
    func cannotEncodeSingleByteShiftJISCharacters(
        message: String
    ) {
        #expect(!KanjiEncoder.canEncode(message))
    }

    @Test(arguments: ["é", "€", "🙂", "𠮷"])
    func cannotEncodeCharactersOutsideShiftJIS(
        message: String
    ) {
        #expect(!KanjiEncoder.canEncode(message))
    }

    // MARK: - characterCount(for:)

    @Test(arguments: [
        ("", 0),
        ("日本語", 3)
    ])
    func characterCountIsCharacterCount(
        message: String,
        expectedCount: Int
    ) {
        #expect(KanjiEncoder.characterCount(for: message) == expectedCount)
    }

    // MARK: - bitCount(forCharacterCount:)

    @Test(arguments: 0...3)
    func bitCountMatchesEncodedBitCount(
        characterCount: Int
    ) {
        let message = String(repeating: "漢", count: characterCount)
        let encodedBitCount = KanjiEncoder.encode(message).count

        #expect(KanjiEncoder.bitCount(forCharacterCount: characterCount) == encodedBitCount)
    }

    // MARK: - encode(_:)

    /// The example from ISO/IEC 18004: 点 (0x935F) and 茗 (0xE4AA),
    /// one from each range of Shift JIS codes.
    @Test
    func encodeStandardExample() {
        let result = KanjiEncoder.encode("点茗")

        #expect(result.bitString == "0110110011111" + "1101010101010")
    }

    @Test(arguments: [
        ("", ""),
        ("\u{3000}", "0000000000000"),  // 0x8140, start of the first range
        ("滌", "1011100111100"),         // 0x9FFC, end of the first range
        ("漾", "1011101000000"),         // 0xE040, start of the second range
        ("熙", "1111100100100")          // 0xEAA4, last character of the second range
    ])
    func encodeRangeBoundaries(
        message: String,
        expectedBits: String
    ) {
        #expect(KanjiEncoder.encode(message).bitString == expectedBits)
    }
}
