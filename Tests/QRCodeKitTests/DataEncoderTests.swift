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
    
    // MARK: - encodeData(_:mode:) - Numeric
    
    @Test
    func encodeNumericSingleDigit() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("7", mode: .numeric)
        
        #expect(result.count == 4)
        #expect(result.bytes == [0b01110000])
    }
    
    @Test
    func encodeNumericTwoDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("42", mode: .numeric)
        
        #expect(result.count == 7)
        #expect(result.bytes == [0b01010100])
    }
    
    @Test
    func encodeNumericThreeDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("987", mode: .numeric)
        
        #expect(result.count == 10)
        #expect(result.bytes == [
            0b11110110,
            0b11000000
        ])
    }
    
    @Test
    func encodeNumericFourDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("3141", mode: .numeric)
        
        #expect(result.count == 14)
        #expect(result.bytes == [
            0b01001110,
            0b10000100
        ])
    }
    
    @Test
    func encodeNumericFiveDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("27182", mode: .numeric)
        
        #expect(result.count == 17)
        #expect(result.bytes == [
            0b01000011,
            0b11101001,
            0b00000000
        ])
    }
    
    @Test
    func encodeNumericSixDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("654321", mode: .numeric)
        
        #expect(result.count == 20)
        #expect(result.bytes == [
            0b10100011,
            0b10010100,
            0b00010000
        ])
    }
    
    @Test
    func encodeNumericMultipleGroupsWithRemainder() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("8675309124", mode: .numeric)
        
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
    func encodeNumericLeadingZeros() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("007", mode: .numeric)
        
        #expect(result.count == 10)
        #expect(result.bytes == [
            0b00000001,
            0b11000000
        ])
    }
    
    @Test
    func encodeNumericZeroInsideGroup() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("507", mode: .numeric)
        
        #expect(result.count == 10)
        #expect(result.bytes == [
            0b01111110,
            0b11000000
        ])
    }
    
    // MARK: - encodeData(_:mode:) - Alphanumeric
    
    @Test
    func encodeAlphanumericSingleCharacter() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("A", mode: .alphanumeric)
        
        #expect(result.count == 6)
        #expect(result.bytes == [0b00101000])
    }
    
    @Test
    func encodeAlphanumericTwoCharacters() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("AZ", mode: .alphanumeric)
        
        #expect(result.count == 11)
        #expect(result.bytes == [
            0b00111100,
            0b10100000
        ])
    }
    
    @Test
    func encodeAlphanumericThreeCharacters() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("09A", mode: .alphanumeric)
        
        #expect(result.count == 17)
        #expect(result.bytes == [
            0b00000001,
            0b00100101,
            0b00000000
        ])
    }
    
    @Test
    func encodeAlphanumericFourCharacters() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("9AZ:", mode: .alphanumeric)
        
        #expect(result.count == 22)
        #expect(result.bytes == [
            0b00110011,
            0b11111001,
            0b01001100
        ])
    }
    
    @Test
    func encodeAlphanumericFiveCharacters() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("Z *./", mode: .alphanumeric)
        
        #expect(result.count == 28)
        #expect(result.bytes == [
            0b11001001,
            0b01111100,
            0b00010110,
            0b10110000
        ])
    }
    
    @Test
    func encodeAlphanumericSingleDigit() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("0", mode: .alphanumeric)
        
        #expect(result.count == 6)
        #expect(result.bytes == [0b00000000])
    }
    
    @Test
    func encodeAlphanumericMaximumPair() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("::", mode: .alphanumeric)
        
        #expect(result.count == 11)
        #expect(result.bytes == [
            0b11111101,
            0b00000000
        ])
    }
    
    // MARK: - encodeData(_:mode:) - Kanji
    
    @Test
    func encodeKanjiSingleCharacter() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("漢", mode: .kanji)
        
        #expect(result.count == 13)
        #expect(result.bytes == [
            0b00111001,
            0b11111000
        ])
    }
    
    @Test
    func encodeKanjiCharactersFromBothRanges() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("海紂", mode: .kanji)
        
        #expect(result.count == 26)
        #expect(result.bytes == [
            0b00110110,
            0b00011110,
            0b01100000,
            0b00000000
        ])
    }
    
    @Test
    func encodeKanjiMultipleCharacters() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("日本語", mode: .kanji)
        
        #expect(result.count == 39)
        #expect(result.bytes == [
            0b01110001,
            0b11010011,
            0b11111110,
            0b11010001,
            0b11010100
        ])
    }
    
    // MARK: - encodeData(_:mode:) - Byte
    
    @Test
    func encodeByteSingleCharacter() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("a", mode: .byte)
        
        #expect(result.count == 8)
        #expect(result.bytes == [0b01100001])
    }
    
    @Test
    func encodeByteNonASCIICharacter() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("é", mode: .byte)
        
        #expect(result.count == 8)
        #expect(result.bytes == [0b11101001])
    }
    
    @Test
    func encodeBytePrintableASCIICharacters() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData(" &9A~", mode: .byte)
        
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
    func encodeByteLatin1SpecialCharacters() {
        let encoder = DataEncoder()
        let nbsp = "\u{00A0}"
        
        let result = encoder.encodeData("\(nbsp)£°µº¿", mode: .byte)
        
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
    func encodeByteUpperLatin1Range() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("ÀÖ×Øß", mode: .byte)
        
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
    func encodeByteLowerLatin1Range() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("àæð÷ÿ", mode: .byte)
        
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
