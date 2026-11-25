//
//  ModeEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 23.11.2026.
//

/// A type that packs the characters of one encoding mode into data bits:
/// the part of a segment after the mode indicator and the character count
/// indicator.
protocol ModeEncoder {
    /// Returns a Boolean value indicating whether the mode can encode
    /// every character of the message.
    static func canEncode(_ message: String) -> Bool

    /// Returns the value of the character count indicator for an encodable
    /// message. Depending on the mode, it counts characters, bytes
    /// or double-byte characters.
    static func characterCount(for message: String) -> Int

    /// Returns the number of data bits for the given number of characters.
    static func bitCount(forCharacterCount characterCount: Int) -> Int

    /// Returns the data bits of an encodable message.
    static func encode(_ message: String) -> BitBuffer
}
