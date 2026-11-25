//
//  EncodingMode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

/// A method of representing a set of characters as bits in a QR code.
public enum EncodingMode: CaseIterable, Hashable, Sendable {
    /// Digits 0–9.
    case numeric

    /// Digits 0–9, uppercase letters A–Z, space and `$ % * + - . / :`.
    case alphanumeric

    /// ISO/IEC 8859-1 (Latin-1) characters.
    case byte

    /// Double-byte Shift JIS characters, such as kanji and kana.
    case kanji
}

// MARK: - Encoding

extension EncodingMode {
    /// The number of bits in a mode indicator.
    static let indicatorBitCount = 4

    /// The value that identifies the mode at the start of a segment.
    var indicator: UInt32 {
        switch self {
        case .numeric:      0b0001
        case .alphanumeric: 0b0010
        case .byte:         0b0100
        case .kanji:        0b1000
        }
    }

    /// The encoder that packs the characters of the mode into data bits.
    var encoder: any ModeEncoder.Type {
        switch self {
        case .numeric:      NumericEncoder.self
        case .alphanumeric: AlphanumericEncoder.self
        case .byte:         ByteEncoder.self
        case .kanji:        KanjiEncoder.self
        }
    }
}
