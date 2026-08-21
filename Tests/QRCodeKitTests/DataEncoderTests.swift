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
    
    //MARK: - encodeData(_:mode:) - Numeric
    
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
        
        let result = encoder.encodeData("12", mode: .numeric)
        
        #expect(result.count == 7)
        #expect(result.bytes == [0b00011000])
    }
    
    @Test
    func encodeNumericThreeDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("123", mode: .numeric)
        
        #expect(result.count == 10)
        #expect(result.bytes == [0b00011110, 0b11000000])
    }
    
    @Test
    func encodeNumericFourDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("1234", mode: .numeric)
        
        #expect(result.count == 14)
        #expect(result.bytes == [0b00011110, 0b11010000])
    }
    
    @Test
    func encodeNumericFiveDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("12345", mode: .numeric)
        
        #expect(result.count == 17)
        #expect(result.bytes == [
            0b00011110,
            0b11010110,
            0b10000000
        ])
    }
    
    @Test
    func encodeNumericSixDigits() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("123456", mode: .numeric)
        
        #expect(result.count == 20)
        #expect(result.bytes == [
            0b00011110,
            0b11011100,
            0b10000000
        ])
    }
    @Test
    func encodeNumericMultipleGroupsWithRemainder() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("1234567890", mode: .numeric)
        
        #expect(result.count == 34)
        #expect(result.bytes == [
            0b00011110,
            0b11011100,
            0b10001100,
            0b01010100,
            0b00000000
        ])
    }
    
    @Test
    func encodeNumericLeadingZeros() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("007", mode: .numeric)
        
        #expect(result.count == 10)
        #expect(result.bytes == [0b00000001, 0b11000000])
    }
    
    @Test
    func encodeNumericZeroInsideGroup() {
        let encoder = DataEncoder()
        
        let result = encoder.encodeData("507", mode: .numeric)
        
        #expect(result.count == 10)
        #expect(result.bytes == [0b01111110, 0b11000000])
    }
    
    //MARK: - encodeData(_:mode:) - Alphaumeric
    
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
        #expect(result.bytes == [0b00111100, 0b10100000])
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
        #expect(result.bytes == [0b11111101, 0b00000000])
    }
}
