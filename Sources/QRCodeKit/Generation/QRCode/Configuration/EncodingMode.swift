//
//  EncodingMode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum EncodingMode: CaseIterable, Sendable {
    case numeric
    case alphanumeric
    case kanji
    case byte

    static let recommendedOrder: [EncodingMode] = [
        .numeric,
        .alphanumeric,
        .kanji,
        .byte
    ]

    var indicator: UInt32 {
        switch self {
        case .numeric:      0b0001
        case .alphanumeric: 0b0010
        case .kanji:        0b1000
        case .byte:         0b0100
        }
    }

    func canEncode(_ message: String) -> Bool {
        switch self {
        case .numeric:      NumericEncoder.canEncode(message)
        case .alphanumeric: AlphanumericEncoder.canEncode(message)
        case .kanji:        KanjiEncoder.canEncode(message)
        case .byte:         ByteEncoder.canEncode(message)
        }
    }

    func characterCount(for message: String) -> Int {
        switch self {
        case .numeric:      NumericEncoder.characterCount(for: message)
        case .alphanumeric: AlphanumericEncoder.characterCount(for: message)
        case .kanji:        KanjiEncoder.characterCount(for: message)
        case .byte:         ByteEncoder.characterCount(for: message)
        }
    }
}
