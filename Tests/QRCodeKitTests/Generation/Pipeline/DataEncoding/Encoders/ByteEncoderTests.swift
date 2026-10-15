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
    func canEncodeASCIICharacters() {
        #expect(ByteEncoder.canEncode("Hello world"))
    }

    @Test
    func canEncodeLatin1Characters() {
        #expect(ByteEncoder.canEncode("Àé£°µ¿ÿ"))
    }

    @Test
    func cannotEncodeEmptyMessage() {
        #expect(!ByteEncoder.canEncode(""))
    }

    @Test(arguments: [
        "€",
        "Ж",
        "🙂",
        "日",
    ])
    func cannotEncodeNonLatin1Character(
        character: String
    ) {
        #expect(!ByteEncoder.canEncode(character))
    }

    // MARK: - characterCount(for:)

    @Test
    func characterCountMatchesEncodedByteCount() {
        let message = "\r\n"

        let count = ByteEncoder.characterCount(
            for: message
        )

        #expect(message.count == 1)
        #expect(count == 2)
    }

    // MARK: - encode(_:)

    @Test
    func encodeSingleASCIICharacter() {
        let result = ByteEncoder.encode("a")

        #expect(result.count == 8)
        #expect(result.bytes == [0b01100001])
    }

    @Test
    func encodeSingleLatin1Character() {
        let result = ByteEncoder.encode("é")

        #expect(result.count == 8)
        #expect(result.bytes == [0b11101001])
    }

    @Test
    func encodeMultipleASCIICharacters() {
        let result = ByteEncoder.encode(" &9A~")

        #expect(result.count == 40)
        #expect(result.bytes == [
            0b00100000,
            0b00100110,
            0b00111001,
            0b01000001,
            0b01111110
        ])
    }

    @Test
    func encodeLatin1SpecialCharacters() {
        let nbsp = "\u{00A0}"

        let result = ByteEncoder.encode(
            "\(nbsp)£°µº¿"
        )

        #expect(result.count == 48)
        #expect(result.bytes == [
            0b10100000,
            0b10100011,
            0b10110000,
            0b10110101,
            0b10111010,
            0b10111111
        ])
    }

    @Test
    func encodeUpperLatin1Range() {
        let result = ByteEncoder.encode("ÀÖ×Øß")

        #expect(result.count == 40)
        #expect(result.bytes == [
            0b11000000,
            0b11010110,
            0b11010111,
            0b11011000,
            0b11011111
        ])
    }

    @Test
    func encodeLowerLatin1Range() {
        let result = ByteEncoder.encode("àæð÷ÿ")

        #expect(result.count == 40)
        #expect(result.bytes == [
            0b11100000,
            0b11100110,
            0b11110000,
            0b11110111,
            0b11111111
        ])
    }
}
