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
        guard !message.isEmpty else {
            return false
        }
        
        switch self {
        case .numeric:      return canEncodeNumeric(message)
        case .alphanumeric: return canEncodeAlphanumeric(message)
        case .kanji:        return canEncodeKanji(message)
        case .byte:         return canEncodeByte(message)
        }
    }
    
    func characterCount(for message: String) -> Int {
        precondition(canEncode(message))
        
        switch self {
        case .byte:
            return message.data(using: .isoLatin1)!.count
        case .numeric, .alphanumeric, .kanji:
            return message.count
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
    
    private func canEncodeKanji(_ message: String) -> Bool {
        message.allSatisfy {
            Kanji.value(for: $0) != nil
        }
    }
    
    private func canEncodeByte(_ message: String) -> Bool {
        message.data(using: .isoLatin1) != nil
    }
}
