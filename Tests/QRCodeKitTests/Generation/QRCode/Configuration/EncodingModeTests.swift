//
//  EncodingModeTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 26.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct EncodingModeTests {
    // MARK: - recommendedOrder

    @Test
    func recommendedOrder() {
        #expect(EncodingMode.recommendedOrder == [
            .numeric,
            .alphanumeric,
            .kanji,
            .byte
        ])
    }

    // MARK: - indicator

    @Test
    func indicators() {
        for mode in EncodingMode.allCases {
            let expectedIndicator: UInt32

            switch mode {
            case .numeric:      expectedIndicator = 0b0001
            case .alphanumeric: expectedIndicator = 0b0010
            case .kanji:        expectedIndicator = 0b1000
            case .byte:         expectedIndicator = 0b0100
            }

            #expect(mode.indicator == expectedIndicator)
        }
    }

    // MARK: - canEncode(_:)

    @Test
    func canEncodeNumeric() {
        #expect(EncodingMode.numeric.canEncode("0123456789"))
        #expect(!EncodingMode.numeric.canEncode("123A"))
    }

    @Test
    func canEncodeAlphanumeric() {
        #expect(EncodingMode.alphanumeric.canEncode("HELLO WORLD 1+2$/3"))
        #expect(!EncodingMode.alphanumeric.canEncode("Hello world"))
    }

    @Test
    func canEncodeKanji() {
        #expect(EncodingMode.kanji.canEncode("日本語"))
        #expect(!EncodingMode.kanji.canEncode("日A"))
    }

    @Test
    func canEncodeByte() {
        #expect(EncodingMode.byte.canEncode("CaféÖæ£¿"))
        #expect(!EncodingMode.byte.canEncode("Café🙂"))
    }

    // MARK: - characterCount(for:)

    @Test
    func characterCountMatchesMessageCharacterCount() {
        #expect(
            EncodingMode.numeric.characterCount(
                for: "0123456789"
            ) == 10
        )

        #expect(
            EncodingMode.alphanumeric.characterCount(
                for: "HELLO WORLD"
            ) == 11
        )

        #expect(
            EncodingMode.kanji.characterCount(
                for: "日本語"
            ) == 3
        )
    }

    @Test
    func characterCountMatchesEncodedByteCount() {
        let count = EncodingMode.byte.characterCount(
            for: "\r\n"
        )

        #expect(count == 2)
    }
}
