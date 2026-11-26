//
//  ByteEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.09.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct ByteEncoderTests {
    // MARK: - canEncode(_:)

    @Test
    func canEncodeEmptyMessage() {
        #expect(ByteEncoder.canEncode(""))
    }

    @Test(arguments: ["Hello world", "Àé£°µ¿ÿ"])
    func canEncodeLatin1Characters(
        message: String
    ) {
        #expect(ByteEncoder.canEncode(message))
    }

    @Test(arguments: ["€", "Ж", "🙂", "日"])
    func cannotEncodeOtherCharacters(
        message: String
    ) {
        #expect(!ByteEncoder.canEncode(message))
    }

    // MARK: - characterCount(for:)

    @Test(arguments: [
        ("", 0),
        ("Café", 4),
        ("\r\n", 2),  // one Character, two bytes
    ])
    func characterCountIsByteCount(
        message: String,
        expectedCount: Int
    ) {
        #expect(ByteEncoder.characterCount(for: message) == expectedCount)
    }

    // MARK: - bitCount(forCharacterCount:)

    @Test(arguments: 0...3)
    func bitCountMatchesEncodedBitCount(
        characterCount: Int
    ) {
        let message = String(repeating: "a", count: characterCount)
        let encodedBitCount = ByteEncoder.encode(message).count

        #expect(ByteEncoder.bitCount(forCharacterCount: characterCount) == encodedBitCount)
    }

    // MARK: - encode(_:)

    @Test(arguments: [
        ("", ""),
        ("a", "01100001"),
        ("é", "11101001"),  // upper half of ISO/IEC 8859-1
        ("ÿ", "11111111"),  // last character of ISO/IEC 8859-1
        ("\r\n", "00001101" + "00001010"),  // one Character, two bytes
    ])
    func encodeLatin1Bytes(
        message: String,
        expectedBits: String
    ) {
        #expect(ByteEncoder.encode(message).bitString == expectedBits)
    }
}
