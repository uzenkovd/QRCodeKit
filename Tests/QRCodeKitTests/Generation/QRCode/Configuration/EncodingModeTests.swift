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
    // MARK: - indicator

    @Test
    func indicators() {
        #expect(EncodingMode.numeric.indicator == 0b0001)
        #expect(EncodingMode.alphanumeric.indicator == 0b0010)
        #expect(EncodingMode.byte.indicator == 0b0100)
        #expect(EncodingMode.kanji.indicator == 0b1000)
    }

    // MARK: - encoder

    @Test
    func encoders() {
        #expect(EncodingMode.numeric.encoder is NumericEncoder.Type)
        #expect(EncodingMode.alphanumeric.encoder is AlphanumericEncoder.Type)
        #expect(EncodingMode.byte.encoder is ByteEncoder.Type)
        #expect(EncodingMode.kanji.encoder is KanjiEncoder.Type)
    }
}
