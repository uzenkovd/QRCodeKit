//
//  QRConfiguration.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.09.2026.
//

/// The parameters a QR code is generated with,
/// resolved from the message and the requested ``QROptions``.
struct QRConfiguration: Equatable {
    let version: QRVersion
    let encodingMode: QREncodingMode
    let errorCorrectionLevel: QRErrorCorrectionLevel
}

// MARK: - Capacity

extension QRConfiguration {
    /// The number of bits in the character count indicator.
    var characterCountIndicatorBitCount: Int {
        CharacterCountIndicator.bitCount(for: version, mode: encodingMode)
    }

    /// The number of bits in the data codewords of the symbol.
    var dataBitCapacity: Int {
        errorCorrectionLayout.totalDataCodewordCount * UInt8.bitWidth
    }

    /// Returns a Boolean value indicating whether a message with the given
    /// number of characters fits in the data codewords of the symbol.
    func canFit(
        characterCount: Int
    ) -> Bool {
        let requiredBitCount =
            QREncodingMode.indicatorBitCount
            + characterCountIndicatorBitCount
            + encodingMode.encoder.bitCount(forCharacterCount: characterCount)

        return requiredBitCount <= dataBitCapacity
    }
}

// MARK: - Error Correction

extension QRConfiguration {
    /// The division of the symbol's codewords into error correction blocks.
    var errorCorrectionLayout: ErrorCorrectionLayout {
        ErrorCorrectionBlocks.layout(for: version, level: errorCorrectionLevel)
    }
}
