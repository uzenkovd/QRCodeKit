//
//  NumericEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

/// The encoder of numeric mode, which packs each group of three digits
/// into 10 bits and a final group of one or two digits into 4 or 7 bits.
enum NumericEncoder: ModeEncoder {
    static func canEncode(
        _ message: String
    ) -> Bool {
        message.utf8.allSatisfy(isDigit)
    }

    static func characterCount(
        for message: String
    ) -> Int {
        precondition(
            canEncode(message),
            "Message cannot be encoded in numeric mode"
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
            groupValue = groupValue * 10 + UInt32(byte - zero)
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

// MARK: - Digits

private extension NumericEncoder {
    static let groupSize = 3

    /// The number of bits in a group, indexed by its length in digits.
    static let groupBitCounts = [0, 4, 7, 10]

    static let zero = UInt8(ascii: "0")
    static let nine = UInt8(ascii: "9")

    static func isDigit(
        _ byte: UInt8
    ) -> Bool {
        (zero...nine).contains(byte)
    }
}
