//
//  Kanji.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 22.08.2026.
//

enum Kanji {
    private static let firstRange: ClosedRange<UInt16> = 0x8140...0x9FFC
    private static let secondRange: ClosedRange<UInt16> = 0xE040...0xEBBF
    
    static func value(for character: Character) -> UInt16? {
        guard let shiftJIS = shiftJISValue(for: character) else {
            return nil
        }
        
        let adjustedValue: UInt16
        
        if firstRange.contains(shiftJIS) {
            adjustedValue = shiftJIS - 0x8140
        } else if secondRange.contains(shiftJIS) {
            adjustedValue = shiftJIS - 0xC140
        } else {
            return nil
        }
        
        let highByte = adjustedValue >> 8
        let lowByte = adjustedValue & 0xFF
        
        return highByte * 0xC0 + lowByte
    }
    
    private static func shiftJISValue(for character: Character) -> UInt16? {
        guard let data = String(character).data(using: .shiftJIS),
              data.count == 2 else {
            return nil
        }
        
        let bytes = [UInt8](data)
        let value = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
        
        return value
    }
}
