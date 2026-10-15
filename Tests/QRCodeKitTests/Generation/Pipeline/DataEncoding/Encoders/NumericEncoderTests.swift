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
    func canEncodeDigits() {
        #expect(NumericEncoder.canEncode("0123456789"))
    }

    @Test
    func cannotEncodeEmptyMessage() {
        #expect(!NumericEncoder.canEncode(""))
    }

    @Test
    func cannotEncodeNonDigitCharacter() {
        #expect(!NumericEncoder.canEncode("123A"))
    }

    @Test
    func cannotEncodeNonASCIIDigits() {
        #expect(!NumericEncoder.canEncode("١٢٣"))
    }

    // MARK: - characterCount(for:)

    @Test
    func characterCountMatchesDigitCount() {
        let count = NumericEncoder.characterCount(
            for: "0123456789"
        )

        #expect(count == 10)
    }

    // MARK: - encode(_:)

    @Test
    func encodeSingleDigit() {
        let result = NumericEncoder.encode("7")

        #expect(result.count == 4)
        #expect(result.bytes == [0b01110000])
    }

    @Test
    func encodeTwoDigits() {
        let result = NumericEncoder.encode("42")

        #expect(result.count == 7)
        #expect(result.bytes == [0b01010100])
    }

    @Test
    func encodeThreeDigits() {
        let result = NumericEncoder.encode("123")

        #expect(result.count == 10)
        #expect(result.bytes == [
            0b00011110,
            0b11000000
        ])
    }

    @Test
    func encodeFourDigits() {
        let result = NumericEncoder.encode("3141")

        #expect(result.count == 14)
        #expect(result.bytes == [
            0b01001110,
            0b10000100
        ])
    }

    @Test
    func encodeFiveDigits() {
        let result = NumericEncoder.encode("27182")

        #expect(result.count == 17)
        #expect(result.bytes == [
            0b01000011,
            0b11101001,
            0b00000000
        ])
    }

    @Test
    func encodeSixDigits() {
        let result = NumericEncoder.encode("654321")

        #expect(result.count == 20)
        #expect(result.bytes == [
            0b10100011,
            0b10010100,
            0b00010000
        ])
    }

    @Test
    func encodeMultipleGroupsWithRemainder() {
        let result = NumericEncoder.encode("8675309124")

        #expect(result.count == 34)
        #expect(result.bytes == [
            0b11011000,
            0b11100001,
            0b00101110,
            0b01000001,
            0b00000000
        ])
    }

    @Test
    func encodeMaximumThreeDigitGroup() {
        let result = NumericEncoder.encode("999")

        #expect(result.count == 10)
        #expect(result.bytes == [
            0b11111001,
            0b11000000
        ])
    }

    @Test
    func encodeLeadingZeros() {
        let result = NumericEncoder.encode("001")

        #expect(result.count == 10)
        #expect(result.bytes == [
            0b00000000,
            0b01000000
        ])
    }
}
