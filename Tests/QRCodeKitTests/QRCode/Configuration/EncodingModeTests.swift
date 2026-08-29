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
        #expect(EncodingMode.numeric.indicator == 0b0001)
        #expect(EncodingMode.alphanumeric.indicator == 0b0010)
        #expect(EncodingMode.kanji.indicator == 0b1000)
        #expect(EncodingMode.byte.indicator == 0b0100)
    }
    
    // MARK: - canEncode(_:)
    
    @Test
    func canEncodeNumeric() {
        #expect(EncodingMode.numeric.canEncode("0123456789"))
        #expect(EncodingMode.numeric.canEncode("0A234B67C9") == false)
        #expect(EncodingMode.numeric.canEncode("ⅲ١¼Ⅳ①❺³₄۴") == false)
    }
    
    @Test
    func canEncodeAlphanumeric() {
        #expect(EncodingMode.alphanumeric.canEncode("HELLO WORLD 1+2$/3"))
        #expect(EncodingMode.alphanumeric.canEncode("HELLO world 1+2$/3") == false)
    }
    
    @Test
    func canEncodeKanji() {
        #expect(EncodingMode.kanji.canEncode("日本語"))
        #expect(EncodingMode.kanji.canEncode("日A2𠮷") == false)
    }
    
    @Test
    func canEncodeByte() {
        #expect(EncodingMode.byte.canEncode("CaféÖæ£¿"))
        #expect(EncodingMode.byte.canEncode("Café🙂𠜎") == false)
    }
    
    @Test
    func cannotEncodeEmptyMessage() {
        for mode in EncodingMode.allCases {
            #expect(mode.canEncode("") == false)
        }
    }
    
    // MARK: - characterCount(for:)
    
    @Test
    func characterCountUsesStringCount() {
        let characterCount = EncodingMode.kanji.characterCount(for: "日本語")
        
        #expect(characterCount == 3)
    }
    
    @Test
    func characterCountUsesByteCount() {
        let characterCount = EncodingMode.byte.characterCount(for: "\r\n")
        
        #expect(characterCount == 2)
    }
}
