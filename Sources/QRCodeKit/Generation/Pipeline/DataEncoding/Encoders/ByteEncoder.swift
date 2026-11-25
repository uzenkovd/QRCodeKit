//
//  ByteEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 14.09.2026.
//

/// The encoder of byte mode, which packs each character into 8 bits
/// in ISO/IEC 8859-1, the character set that decoders assume by default.
enum ByteEncoder: ModeEncoder {
    static func canEncode(
        _ message: String
    ) -> Bool {
        latin1Bytes(for: message) != nil
    }

    static func characterCount(
        for message: String
    ) -> Int {
        validatedLatin1Bytes(for: message).count
    }

    static func bitCount(
        forCharacterCount characterCount: Int
    ) -> Int {
        characterCount * UInt8.bitWidth
    }

    static func encode(
        _ message: String
    ) -> BitBuffer {
        let bytes = validatedLatin1Bytes(for: message)

        var buffer = BitBuffer()
        buffer.append(contentsOf: bytes)

        return buffer
    }
}

// MARK: - ISO/IEC 8859-1

private extension ByteEncoder {
    /// Returns the bytes of the message in ISO/IEC 8859-1, or `nil`
    /// if a character is outside the character set.
    static func latin1Bytes(
        for message: String
    ) -> [UInt8]? {
        var bytes: [UInt8] = []

        // ISO/IEC 8859-1 matches the first 256 Unicode code points
        for scalar in message.unicodeScalars {
            guard let byte = UInt8(exactly: scalar.value) else {
                return nil
            }

            bytes.append(byte)
        }

        return bytes
    }

    static func validatedLatin1Bytes(
        for message: String
    ) -> [UInt8] {
        guard let bytes = latin1Bytes(for: message) else {
            preconditionFailure("Message cannot be encoded in byte mode")
        }

        return bytes
    }
}
