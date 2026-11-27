//
//  QRConfiguration+Testing.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 25.11.2026.
//

@testable import QRCodeKit

extension QRConfiguration {
    /// Creates a configuration with its parameters in the order of the
    /// standard's notation, such as 1-Q: version, then level, then mode.
    init(
        _ version: QRVersion,
        _ errorCorrectionLevel: QRErrorCorrectionLevel,
        _ encodingMode: QREncodingMode
    ) {
        self.init(
            version: version,
            encodingMode: encodingMode,
            errorCorrectionLevel: errorCorrectionLevel
        )
    }
}
