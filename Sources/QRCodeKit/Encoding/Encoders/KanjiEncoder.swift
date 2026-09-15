//
//  KanjiEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

enum KanjiEncoder {
    static func canEncode(_ message: String) -> Bool {
        guard !message.isEmpty else {
            return false
        }

        return message.allSatisfy {
            value(for: $0) != nil
        }
    }

    static func characterCount(
        for message: String
    ) -> Int {
        precondition(
            canEncode(message),
            "Message cannot be encoded in kanji mode"
        )

        return message.count
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        precondition(
            canEncode(message),
            "Message cannot be encoded in kanji mode"
        )

        var buffer = BitBuffer()

        for character in message {
            let value = value(for: character)!
            buffer.append(UInt32(value), bitCount: 13)
        }

        return buffer
    }
}

// MARK: - Kanji Value Conversion

private extension KanjiEncoder {
    static let firstShiftJISRange: ClosedRange<UInt16> =
        0x8140...0x9FFC
    static let secondShiftJISRange: ClosedRange<UInt16> =
        0xE040...0xEBBF

    static func value(
        for character: Character
    ) -> UInt16? {
        guard let shiftJIS = shiftJISValue(for: character) else {
            return nil
        }

        let adjustedValue: UInt16

        if firstShiftJISRange.contains(shiftJIS) {
            adjustedValue = shiftJIS - 0x8140
        } else if secondShiftJISRange.contains(shiftJIS) {
            adjustedValue = shiftJIS - 0xC140
        } else {
            return nil
        }

        let highByte = adjustedValue >> 8
        let lowByte = adjustedValue & 0xFF

        return highByte * 0xC0 + lowByte
    }

    static func shiftJISValue(
        for character: Character
    ) -> UInt16? {
        guard let data = String(character).data(using: .shiftJIS),
              data.count == 2 else {
            return nil
        }

        let bytes = [UInt8](data)
        let highByte = UInt16(bytes[0])
        let lowByte = UInt16(bytes[1])

        return highByte << 8 | lowByte
    }
}
