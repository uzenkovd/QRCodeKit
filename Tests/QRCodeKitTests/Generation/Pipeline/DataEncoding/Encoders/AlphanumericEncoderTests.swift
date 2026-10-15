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
    func canEncodeSupportedCharacters() {
        #expect(
            AlphanumericEncoder.canEncode(
                "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
            )
        )
    }

    @Test
    func cannotEncodeEmptyMessage() {
        #expect(!AlphanumericEncoder.canEncode(""))
    }

    @Test
    func cannotEncodeLowercaseCharacter() {
        #expect(!AlphanumericEncoder.canEncode("ABCd"))
    }

    @Test
    func cannotEncodeNonASCIICharacter() {
        #expect(!AlphanumericEncoder.canEncode("CAFÉ"))
    }

    // MARK: - characterCount(for:)

    @Test
    func characterCountMatchesCharacterCount() {
        let count = AlphanumericEncoder.characterCount(
            for: "HELLO WORLD"
        )

        #expect(count == 11)
    }

    // MARK: - encode(_:)

    @Test
    func encodeSingleCharacter() {
        let result = AlphanumericEncoder.encode("A")

        #expect(result.count == 6)
        #expect(result.bytes == [0b00101000])
    }

    @Test
    func encodeTwoCharacters() {
        let result = AlphanumericEncoder.encode("AZ")

        #expect(result.count == 11)
        #expect(result.bytes == [
            0b00111100,
            0b10100000
        ])
    }

    @Test
    func encodeThreeCharacters() {
        let result = AlphanumericEncoder.encode("09A")

        #expect(result.count == 17)
        #expect(result.bytes == [
            0b00000001,
            0b00100101,
            0b00000000
        ])
    }

    @Test
    func encodeFourCharacters() {
        let result = AlphanumericEncoder.encode("A1 $")

        #expect(result.count == 22)
        #expect(result.bytes == [
            0b00111000,
            0b01111001,
            0b11100100
        ])
    }

    @Test
    func encodeMultipleGroupsWithRemainder() {
        let result = AlphanumericEncoder.encode("Z *./")

        #expect(result.count == 28)
        #expect(result.bytes == [
            0b11001001,
            0b01111100,
            0b00010110,
            0b10110000
        ])
    }

    @Test
    func encodeMaximumPair() {
        let result = AlphanumericEncoder.encode("::")

        #expect(result.count == 11)
        #expect(result.bytes == [
            0b11111101,
            0b00000000
        ])
    }
}
