//
//  QREncodingModeTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 26.08.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct QREncodingModeTests {
    // MARK: - indicator

    @Test
    func indicators() {
        #expect(QREncodingMode.numeric.indicator == 0b0001)
        #expect(QREncodingMode.alphanumeric.indicator == 0b0010)
        #expect(QREncodingMode.byte.indicator == 0b0100)
        #expect(QREncodingMode.kanji.indicator == 0b1000)
    }

    // MARK: - encoder

    @Test
    func encoders() {
        #expect(QREncodingMode.numeric.encoder is NumericEncoder.Type)
        #expect(QREncodingMode.alphanumeric.encoder is AlphanumericEncoder.Type)
        #expect(QREncodingMode.byte.encoder is ByteEncoder.Type)
        #expect(QREncodingMode.kanji.encoder is KanjiEncoder.Type)
    }
}
