//
//  NumericEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

enum NumericEncoder {
    static func canEncode(_ message: String) -> Bool {
        guard !message.isEmpty else {
            return false
        }

        return message.allSatisfy { character in
            guard let asciiValue = character.asciiValue else {
                return false
            }

            return (48...57).contains(asciiValue)
        }
    }

    static func characterCount(
        for message: String
    ) -> Int {
        precondition(
            canEncode(message),
            "Message cannot be encoded in numeric mode"
        )

        return message.count
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        precondition(
            canEncode(message),
            "Message cannot be encoded in numeric mode"
        )

        var buffer = BitBuffer()
        var groupValue: UInt32 = 0
        var digitCount = 0

        for character in message {
            let digit = digitValue(for: character)

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

    private static func digitValue(
        for character: Character
    ) -> UInt32 {
        UInt32(character.asciiValue! - 48)
    }
}
