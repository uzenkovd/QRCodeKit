//
//  EncodingMode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

import Foundation

public enum EncodingMode: CaseIterable, Sendable {
    case numeric
    case alphanumeric
    case kanji
    case byte
    
    static let recommendedOrder: [EncodingMode] = [
        .numeric,
        .alphanumeric,
        .kanji,
        .byte
    ]
    
    var indicator: UInt32 {
        switch self {
        case .numeric:      0b0001
        case .alphanumeric: 0b0010
        case .kanji:        0b1000
        case .byte:         0b0100
            
        }
    }
    
    func canEncode(_ message: String) -> Bool {
        precondition(!message.isEmpty)
        
        switch self {
        case .numeric:      return canEncodeNumeric(message)
        case .alphanumeric: return canEncodeAlphanumeric(message)
        case .kanji:        return canEncodeKanji(message)
        case .byte:         return canEncodeByte(message)
        }
    }
    
    private func canEncodeNumeric(_ message: String) -> Bool {
        message.allSatisfy { character in
            guard let asciiValue = character.asciiValue else {
                return false
            }
            
            return asciiValue >= 48 && asciiValue <= 57
        }
    }
    
    private func canEncodeAlphanumeric(_ message: String) -> Bool {
        message.allSatisfy {
            Alphanumeric.contains($0)
        }
    }
    
    private func canEncodeByte(_ message: String) -> Bool {
        message.canBeConverted(to: .isoLatin1)
    }
    
    private func canEncodeKanji(_ message: String) -> Bool {
        for character in message {
            let string = String(character)
            guard let data = string.data(using: .shiftJIS) else {
                return false
            }
            
            let bytes = [UInt8](data)
            guard bytes.count == 2 else {
                return false
            }
            
            let shiftJISCode = (UInt16(bytes[0]) << 8) | UInt16(bytes[1])
            guard isInFirstRange(shiftJISCode) || isInSecondRange(shiftJISCode) else {
                return false
            }
        }
        
        return true
    }
    
    private func isInFirstRange(_ shiftJISCode: UInt16) -> Bool {
        shiftJISCode >= 0x8140 && shiftJISCode <= 0x9FFC
    }
    
    private func isInSecondRange(_ shiftJISCode: UInt16) -> Bool {
        shiftJISCode >= 0xE040 && shiftJISCode <= 0xEBBF
    }
}
