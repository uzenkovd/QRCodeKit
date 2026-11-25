//
//  AlphanumericEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct AlphanumericEncoderTests {
    // MARK: - canEncode(_:)

    @Test
    func canEncodeEmptyMessage() {
        #expect(AlphanumericEncoder.canEncode(""))
    }

    @Test
    func canEncodeAllCharacters() {
        #expect(AlphanumericEncoder.canEncode("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"))
    }

    @Test(arguments: ["ABCd", "A_B", "CAFÉ"])
    func cannotEncodeOtherCharacters(
        message: String
    ) {
        #expect(!AlphanumericEncoder.canEncode(message))
    }

    // MARK: - characterCount(for:)

    @Test(arguments: [
        ("", 0),
        ("HELLO WORLD", 11)
    ])
    func characterCountIsCharacterCount(
        message: String,
        expectedCount: Int
    ) {
        #expect(AlphanumericEncoder.characterCount(for: message) == expectedCount)
    }

    // MARK: - bitCount(forCharacterCount:)

    @Test(arguments: 0...5)
    func bitCountMatchesEncodedBitCount(
        characterCount: Int
    ) {
        let message = String(repeating: "A", count: characterCount)
        let encodedBitCount = AlphanumericEncoder.encode(message).count

        #expect(AlphanumericEncoder.bitCount(forCharacterCount: characterCount) == encodedBitCount)
    }

    // MARK: - encode(_:)

    /// The example from ISO/IEC 18004: the pairs AC and -4, and the final 2.
    @Test
    func encodeStandardExample() {
        let result = AlphanumericEncoder.encode("AC-42")

        #expect(result.bitString == "00111001110" + "11100111001" + "000010")
    }

    @Test(arguments: [
        ("", ""),
        ("A", "001010"),                                     // final single character
        ("AZ", "00111100101"),                               // pair
        ("::", "11111101000"),                               // largest pair value
        ("Z *./", "11001001011" + "11100000101" + "101011")  // symbols
    ])
    func encodePairsOfCharacters(
        message: String,
        expectedBits: String
    ) {
        #expect(AlphanumericEncoder.encode(message).bitString == expectedBits)
    }
}
