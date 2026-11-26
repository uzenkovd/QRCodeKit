//
//  NumericEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct NumericEncoderTests {
    // MARK: - canEncode(_:)

    @Test
    func canEncodeEmptyMessage() {
        #expect(NumericEncoder.canEncode(""))
    }

    @Test
    func canEncodeDigits() {
        #expect(NumericEncoder.canEncode("0123456789"))
    }

    @Test(arguments: ["123A", "12 3", "١٢٣"])
    func cannotEncodeNonDigitCharacters(
        message: String
    ) {
        #expect(!NumericEncoder.canEncode(message))
    }

    // MARK: - characterCount(for:)

    @Test(arguments: [
        ("", 0),
        ("0123456789", 10),
    ])
    func characterCountIsDigitCount(
        message: String,
        expectedCount: Int
    ) {
        #expect(NumericEncoder.characterCount(for: message) == expectedCount)
    }

    // MARK: - bitCount(forCharacterCount:)

    @Test(arguments: 0...7)
    func bitCountMatchesEncodedBitCount(
        characterCount: Int
    ) {
        let message = String(repeating: "9", count: characterCount)
        let encodedBitCount = NumericEncoder.encode(message).count

        #expect(NumericEncoder.bitCount(forCharacterCount: characterCount) == encodedBitCount)
    }

    // MARK: - encode(_:)

    /// The example from ISO/IEC 18004: the groups 012, 345 and 67.
    @Test
    func encodeStandardExample() {
        let result = NumericEncoder.encode("01234567")

        #expect(result.bitString == "0000001100" + "0101011001" + "1000011")
    }

    @Test(arguments: [
        ("", ""),
        ("7", "0111"),  // final group of one digit
        ("42", "0101010"),  // final group of two digits
        ("123", "0001111011"),  // full group
        ("3141", "0100111010" + "0001"),  // full group and one digit
        ("001", "0000000001"),  // leading zeros
        ("999", "1111100111"),  // largest group value
    ])
    func encodeGroupsOfDigits(
        message: String,
        expectedBits: String
    ) {
        #expect(NumericEncoder.encode(message).bitString == expectedBits)
    }
}
