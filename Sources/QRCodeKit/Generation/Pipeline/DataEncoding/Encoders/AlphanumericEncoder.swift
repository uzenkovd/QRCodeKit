//
//  AlphanumericEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

/// The encoder of alphanumeric mode, which packs each pair of characters
/// into 11 bits and a final single character into 6 bits.
enum AlphanumericEncoder: ModeEncoder {
    static func canEncode(
        _ message: String
    ) -> Bool {
        message.utf8.allSatisfy { values[$0] != nil }
    }

    static func characterCount(
        for message: String
    ) -> Int {
        precondition(
            canEncode(message),
            "Message cannot be encoded in alphanumeric mode"
        )

        return message.utf8.count
    }

    static func bitCount(
        forCharacterCount characterCount: Int
    ) -> Int {
        let fullGroupCount = characterCount / groupSize
        let finalGroupLength = characterCount % groupSize

        return fullGroupCount * groupBitCounts[groupSize]
            + groupBitCounts[finalGroupLength]
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        let characterCount = characterCount(for: message)
        let capacity = bitCount(forCharacterCount: characterCount)

        var buffer = BitBuffer(minimumCapacity: capacity)

        var groupValue: UInt32 = 0
        var groupLength = 0

        for byte in message.utf8 {
            // Never nil: characterCount(for:) checks that every byte is valid
            groupValue = groupValue * 45 + values[byte]!
            groupLength += 1

            if groupLength == groupSize {
                buffer.append(groupValue, bitCount: groupBitCounts[groupLength])

                groupValue = 0
                groupLength = 0
            }
        }

        if groupLength > 0 {
            buffer.append(groupValue, bitCount: groupBitCounts[groupLength])
        }

        return buffer
    }
}

// MARK: - Characters

private extension AlphanumericEncoder {
    static let groupSize = 2

    /// The number of bits in a group, indexed by its length in characters.
    static let groupBitCounts = [0, 6, 11]

    /// The characters of alphanumeric mode in the order of their values
    /// in ISO/IEC 18004.
    static let characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"

    /// The value of each character, keyed by its ASCII byte.
    static let values: [UInt8: UInt32] = Dictionary(
        uniqueKeysWithValues: characters.utf8.enumerated().map { index, byte in
            (byte, UInt32(index))
        }
    )
}
