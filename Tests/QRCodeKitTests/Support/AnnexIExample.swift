//
//  AnnexIExample.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.11.2026.
//

@testable import QRCodeKit

/// The worked example from ISO/IEC 18004, Annex I: "01234567"
/// encoded as a 1-M symbol, for which the encoder selects mask 2.
enum AnnexIExample {
    static let message = "01234567"
    static let version: QRVersion = .v1
    static let encodingMode: QREncodingMode = .numeric
    static let errorCorrectionLevel: QRErrorCorrectionLevel = .M
    static let mask: QRMask = .pattern2

    /// The final message from the example: 16 data codewords
    /// followed by 10 error correction codewords.
    static let codewords: [UInt8] = [
        0x10, 0x20, 0x0C, 0x56, 0x61, 0x80, 0xEC, 0x11,
        0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11,
        0xA5, 0x24, 0xD4, 0xC1, 0xED, 0x36, 0xC7, 0x87,
        0x2C, 0x55,
    ]

    /// The data codewords: the first 16 codewords of the final message.
    static let dataCodewords = Array(codewords.prefix(16))

    /// The colors of the finished symbol from Figure I.2, row by row.
    static let moduleColors: [[QRModuleColor]] =
        snapshot
        .split(separator: "\n")
        .map { row in
            row.map { $0 == "1" ? .dark : .light }
        }
}

// MARK: - Snapshot

private extension AnnexIExample {
    /// Figure I.2 as a binary snapshot, where 1 is a dark module.
    static let snapshot = """
        111111100101101111111
        100000100111101000001
        101110101000001011101
        101110101100001011101
        101110101011101011101
        100000101000101000001
        111111101010101111111
        000000001001100000000
        101111100100101111100
        000101011010100101100
        001000110101010011111
        000010000100000111100
        000111111001010010000
        000000001011111001100
        111111100110101100000
        100000101011111000101
        101110101000100101100
        101110101100100100000
        101110101011010010100
        100000100000000110110
        111111101111010010100
        """
}
