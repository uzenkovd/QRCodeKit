//
//  KanjiEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

import Foundation

/// The encoder of kanji mode, which packs each double-byte Shift JIS
/// character into 13 bits.
enum KanjiEncoder: ModeEncoder {
    static func canEncode(
        _ message: String
    ) -> Bool {
        values(for: message) != nil
    }

    static func characterCount(
        for message: String
    ) -> Int {
        validatedValues(for: message).count
    }

    static func bitCount(
        forCharacterCount characterCount: Int
    ) -> Int {
        characterCount * bitCountPerCharacter
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        let values = validatedValues(for: message)
        let capacity = bitCount(forCharacterCount: values.count)

        var buffer = BitBuffer(minimumCapacity: capacity)

        for value in values {
            buffer.append(UInt32(value), bitCount: bitCountPerCharacter)
        }

        return buffer
    }
}

// MARK: - Shift JIS

private extension KanjiEncoder {
    static let bitCountPerCharacter = 13

    /// The ranges of double-byte Shift JIS codes that kanji mode encodes,
    /// each with the offset subtracted from its codes.
    static let codeRanges: [(codes: ClosedRange<UInt16>, offset: UInt16)] = [
        (0x8140...0x9FFC, 0x8140),
        (0xE040...0xEBBF, 0xC140)
    ]

    /// Returns the 13-bit values of the message's characters, or `nil`
    /// if a character cannot be encoded in kanji mode.
    static func values(
        for message: String
    ) -> [UInt16]? {
        var values: [UInt16] = []

        for character in message {
            guard let value = value(for: character) else {
                return nil
            }

            values.append(value)
        }

        return values
    }

    static func validatedValues(
        for message: String
    ) -> [UInt16] {
        guard let values = values(for: message) else {
            preconditionFailure("Message cannot be encoded in kanji mode")
        }

        return values
    }

    /// Returns the 13-bit value of the character as defined in ISO/IEC 18004,
    /// or `nil` if the character cannot be encoded in kanji mode.
    static func value(
        for character: Character
    ) -> UInt16? {
        guard
            let code = shiftJISCode(for: character),
            let range = codeRanges.first(where: { $0.codes.contains(code) })
        else {
            return nil
        }

        let adjustedCode = code - range.offset
        let highByte = adjustedCode >> 8
        let lowByte = adjustedCode & 0xFF

        return highByte * 0xC0 + lowByte
    }

    /// Returns the double-byte Shift JIS code of the character, or `nil`
    /// if the character is not in Shift JIS or is encoded in a single byte.
    static func shiftJISCode(
        for character: Character
    ) -> UInt16? {
        guard
            let data = String(character).data(using: .shiftJIS),
            data.count == 2
        else {
            return nil
        }

        let bytes = [UInt8](data)

        return UInt16(bytes[0]) << 8 | UInt16(bytes[1])
    }
}
