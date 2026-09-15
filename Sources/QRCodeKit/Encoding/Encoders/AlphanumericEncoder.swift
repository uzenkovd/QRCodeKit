//
//  AlphanumericEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

enum AlphanumericEncoder {
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
            "Message cannot be encoded in alphanumeric mode"
        )

        return message.count
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        precondition(
            canEncode(message),
            "Message cannot be encoded in alphanumeric mode"
        )

        var buffer = BitBuffer()
        var groupValue: UInt32 = 0
        var groupCharacterCount = 0

        for character in message {
            let value = value(for: character)!

            groupValue = groupValue * 45 + value
            groupCharacterCount += 1

            if groupCharacterCount == 2 {
                buffer.append(groupValue, bitCount: 11)

                groupValue = 0
                groupCharacterCount = 0
            }
        }

        if groupCharacterCount == 1 {
            buffer.append(groupValue, bitCount: 6)
        }

        return buffer
    }
}

// MARK: - Alphanumeric Table

private extension AlphanumericEncoder {
    static func value(
        for character: Character
    ) -> UInt32? {
        table[character]
    }

    static let table: [Character: UInt32] = [
        "0": 0,
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "A": 10,
        "B": 11,
        "C": 12,
        "D": 13,
        "E": 14,
        "F": 15,
        "G": 16,
        "H": 17,
        "I": 18,
        "J": 19,
        "K": 20,
        "L": 21,
        "M": 22,
        "N": 23,
        "O": 24,
        "P": 25,
        "Q": 26,
        "R": 27,
        "S": 28,
        "T": 29,
        "U": 30,
        "V": 31,
        "W": 32,
        "X": 33,
        "Y": 34,
        "Z": 35,
        " ": 36,
        "$": 37,
        "%": 38,
        "*": 39,
        "+": 40,
        "-": 41,
        ".": 42,
        "/": 43,
        ":": 44
    ]
}
