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
    let encodingMode: EncodingMode
    let errorCorrectionLevel: ErrorCorrectionLevel

    var errorCorrectionLayout: ErrorCorrectionLayout {
        ErrorCorrectionBlocks.layout(
            for: version,
            level: errorCorrectionLevel
        )
    }
}
