//
//  ByteEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

import Foundation

enum ByteEncoder {
    static func canEncode(_ message: String) -> Bool {
        latin1Data(for: message) != nil
    }

    static func characterCount(
        for message: String
    ) -> Int {
        validatedLatin1Data(for: message).count
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        let data = validatedLatin1Data(for: message)

        var buffer = BitBuffer()

        for byte in data {
            buffer.append(byte)
        }

        return buffer
    }
}

// MARK: - ISO Latin-1

private extension ByteEncoder {
    static func latin1Data(
        for message: String
    ) -> Data? {
        guard !message.isEmpty else {
            return nil
        }

        return message.data(using: .isoLatin1)
    }

    static func validatedLatin1Data(
        for message: String
    ) -> Data {
        guard let data = latin1Data(for: message) else {
            preconditionFailure(
                "Message cannot be encoded in byte mode"
            )
        }

        return data
    }
}
