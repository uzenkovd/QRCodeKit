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
        
        let characterCountIndicator = UInt32(message.count)
        let characterCountIndicatorLength = CharacterCountIndicatorLengths.length(
            for: version,
            mode: mode
        )
        
        let encodedData = encodeData(message, mode: mode)
        
        var buffer = BitBuffer()
        
        buffer.append(modeIndicator, bitCount: 4)
        buffer.append(
            characterCountIndicator,
            bitCount: characterCountIndicatorLength
        )
        //buffer.append(contentsOf: encodedData)
        
        return buffer.bytes
    }
    
    func encodeData(_ message: String, mode: EncodingMode) -> BitBuffer {
        precondition(mode.canEncode(message))
        
        switch mode {
        case .numeric:      return encodeNumeric(message)
        case .alphanumeric: return encodeAlphanumeric(message)
        case .kanji:        return BitBuffer()
        case .byte:         return BitBuffer()
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
    
    private func numericValue(of character: Character) -> UInt32 {
        UInt32(character.asciiValue! - 48)
    }
}
