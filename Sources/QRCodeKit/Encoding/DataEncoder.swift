//
//  DataEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.08.2026.
//

struct DataEncoder {
    func encode(
        _ message: String,
        mode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel,
        version: QRVersion
    ) -> [UInt8] {
        let modeIndicator = mode.indicator
        let modeIndicatorLength = 4
        
        let encodedData = encodeData(message, mode: mode)
        
        let characterCountIndicator: UInt32
        
        switch mode {
        case .byte:
            characterCountIndicator = UInt32(encodedData.byteCount)
        case .numeric, .alphanumeric, .kanji:
            characterCountIndicator = UInt32(message.count)
        }

        let characterCountIndicatorLength = CharacterCountIndicatorLengths.length(
            for: version,
            mode: mode
        )
        
        let totalDataCodewords = ErrorCorrectionBlocks.totalDataCodewords(
            for: version,
            level: errorCorrectionLevel
        )
        
        let totalDataBits = totalDataCodewords * 8
        var currentDataBits = (
            modeIndicatorLength +
            characterCountIndicatorLength +
            encodedData.count
        )
        
        precondition(
            currentDataBits <= totalDataBits,
            "Encoded data exceeds the selected version and error correction level capacity"
        )
        
        let remainingDataBits = totalDataBits - currentDataBits
        let terminatorLength = min(4, remainingDataBits)
        
        currentDataBits += terminatorLength
        
        let byteAlignmentLength = (8 - currentDataBits % 8) % 8
        
        currentDataBits += byteAlignmentLength
        
        let padByteCount = (totalDataBits - currentDataBits) / 8
        let padBytes = makePadBytes(count: padByteCount)
        
        var buffer = BitBuffer()
        
        buffer.append(modeIndicator, bitCount: modeIndicatorLength)
        buffer.append(characterCountIndicator, bitCount: characterCountIndicatorLength)
        buffer.append(contentsOf: encodedData)
        buffer.append(0, bitCount: terminatorLength)
        buffer.append(0, bitCount: byteAlignmentLength)
        buffer.append(contentsOf: padBytes)
        
        assert(
            buffer.count == totalDataBits,
            "Encoded data does not match the expected data capacity"
        )
        
        return buffer.bytes
    }
    
    func encodeData(_ message: String, mode: EncodingMode) -> BitBuffer {
        precondition(mode.canEncode(message))
        
        switch mode {
        case .numeric:      return encodeNumeric(message)
        case .alphanumeric: return encodeAlphanumeric(message)
        case .kanji:        return encodeKanji(message)
        case .byte:         return encodeByte(message)
        }
    }
    
    private func encodeNumeric(_ message: String) -> BitBuffer {
        var buffer = BitBuffer()
        var groupValue: UInt32 = 0
        var digitCount = 0
        
        for character in message {
            let digit = numericValue(of: character)
            
            groupValue = groupValue * 10 + digit
            digitCount += 1
            
            if digitCount == 3 {
                buffer.append(groupValue, bitCount: 10)
                
                groupValue = 0
                digitCount = 0
            }
        }
        
        if digitCount == 1 {
            buffer.append(groupValue, bitCount: 4)
        } else if digitCount == 2 {
            buffer.append(groupValue, bitCount: 7)
        }
        
        return buffer
    }
    
    private func encodeAlphanumeric(_ message: String) -> BitBuffer {
        var buffer = BitBuffer()
        var groupValue: UInt32 = 0
        var characterCount = 0
        
        for character in message {
            let value = Alphanumeric.value(for: character)!
            
            groupValue = groupValue * 45 + value
            characterCount += 1
            
            if characterCount == 2 {
                buffer.append(groupValue, bitCount: 11)
                
                groupValue = 0
                characterCount = 0
            }
        }
        
        if characterCount == 1 {
            buffer.append(groupValue, bitCount: 6)
        }
        
        return buffer
    }
    
    private func encodeKanji(_ message: String) -> BitBuffer {
        var buffer = BitBuffer()
        
        for character in message {
            let value = Kanji.value(for: character)!
            buffer.append(UInt32(value), bitCount: 13)
        }
        
        return buffer
    }
    
    private func encodeByte(_ message: String) -> BitBuffer {
        var buffer = BitBuffer()
        
        let data = message.data(using: .isoLatin1)!
        
        for byte in data {
            buffer.append(byte)
        }
        
        return buffer
    }
    
    private func makePadBytes(count: Int) -> BitBuffer {
        var buffer = BitBuffer()
        let padByteValues: [UInt8] = [0xEC, 0x11]
        
        for index in 0..<count {
            let byte = padByteValues[index % padByteValues.count]
            buffer.append(byte)
        }
        
        return buffer
    }
    
    private func numericValue(of character: Character) -> UInt32 {
        UInt32(character.asciiValue! - 48)
    }
}
