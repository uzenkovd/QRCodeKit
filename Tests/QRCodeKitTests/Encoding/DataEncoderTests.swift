//
//  DataEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct DataEncoderTests {
    // MARK: - Numeric

    @Test
    func encodeNumericVersion1High() {
        let encoder = DataEncoder()

        let result = encoder.encode(
            "1",
            mode: .numeric,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(result == [
            0b00010000,
            0b00000100,
            0b01000000,
            0xEC,
            0x11,
            0xEC,
            0x11,
            0xEC,
            0x11
        ])
    }

    @Test
    func encodeNumericAtExactCapacity() {
        let encoder = DataEncoder()
        let message = "1234567890123456789012345678901234"

        let result = encoder.encode(
            message,
            mode: .numeric,
            version: .v1,
            errorCorrectionLevel: .M
        )

        #expect(result == [
            0b00010000,
            0b10001000,
            0b01111011,
            0b01110010,
            0b00110001,
            0b01010000,
            0b00110001,
            0b01011001,
            0b10101001,
            0b10111000,
            0b01010011,
            0b10101010,
            0b00110111,
            0b11011110,
            0b10000111,
            0b10110100
        ])
    }

    // MARK: - Alphanumeric

    @Test
    func encodeAlphanumericVersion1High() {
        let encoder = DataEncoder()

        let result = encoder.encode(
            "A",
            mode: .alphanumeric,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(result == [
            0b00100000,
            0b00001001,
            0b01000000,
            0xEC,
            0x11,
            0xEC,
            0x11,
            0xEC,
            0x11
        ])
    }

    @Test
    func encodeAlphanumericWithShortenedTerminator() {
        let encoder = DataEncoder()
        let message = "ABCDEFGHIJKLMNOP"

        let result = encoder.encode(
            message,
            mode: .alphanumeric,
            version: .v1,
            errorCorrectionLevel: .Q
        )

        #expect(result == [
            0b00100000,
            0b10000001,
            0b11001101,
            0b01000101,
            0b00101010,
            0b00010101,
            0b01110000,
            0b10110011,
            0b11010111,
            0b00110010,
            0b11111101,
            0b01100010,
            0b10001000
        ])
    }

    // MARK: - Kanji

    @Test
    func encodeKanjiVersion1High() {
        let encoder = DataEncoder()

        let result = encoder.encode(
            "漢",
            mode: .kanji,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(result == [
            0b10000000,
            0b00010011,
            0b10011111,
            0b10000000,
            0xEC,
            0x11,
            0xEC,
            0x11,
            0xEC
        ])
    }

    @Test
    func encodeKanjiUsesVersionSpecificCharacterCountIndicatorLength() {
        let encoder = DataEncoder()

        let result = encoder.encode(
            "海",
            mode: .kanji,
            version: .v10,
            errorCorrectionLevel: .H
        )

        #expect(result.count == 122)
        #expect(result.prefix(10) == [
            0b10000000,
            0b00000100,
            0b11011000,
            0b01100000,
            0xEC,
            0x11,
            0xEC,
            0x11,
            0xEC,
            0x11
        ])
    }

    // MARK: - Byte

    @Test
    func encodeByteVersion1High() {
        let encoder = DataEncoder()

        let result = encoder.encode(
            "a",
            mode: .byte,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(result == [
            0b01000000,
            0b00010110,
            0b00010000,
            0xEC,
            0x11,
            0xEC,
            0x11,
            0xEC,
            0x11
        ])
    }

    @Test
    func encodeByteUsesByteCountForCharacterCountIndicator() {
        let encoder = DataEncoder()

        let result = encoder.encode(
            "\r\n",
            mode: .byte,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(result == [
            0b01000000,
            0b00100000,
            0b11010000,
            0b10100000,
            0xEC,
            0x11,
            0xEC,
            0x11,
            0xEC
        ])
    }
}
