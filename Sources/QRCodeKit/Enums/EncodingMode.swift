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
    
    func canEncode(_ message: String) -> Bool {
        switch self {
        case .numeric:
            return message.allSatisfy { $0 >= "0" && $0 <= "9" }
        case .alphanumeric:
            return message.allSatisfy {
                AlphanumericTable.values[$0] != nil
            }
        case .kanji:
            return canEncodeKanji(message)
        case .byte:
            return message.canBeConverted(to: .isoLatin1)
        }
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
