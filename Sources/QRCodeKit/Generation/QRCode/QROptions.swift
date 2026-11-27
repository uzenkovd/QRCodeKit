//
//  QROptions.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public struct QROptions: Hashable, Sendable {
    public var version: QRVersion?
    public var encodingMode: QREncodingMode?
    public var errorCorrectionLevel: QRErrorCorrectionLevel?
    public var mask: QRMask?

    public init(
        version: QRVersion? = nil,
        encodingMode: QREncodingMode? = nil,
        errorCorrectionLevel: QRErrorCorrectionLevel? = nil,
        mask: QRMask? = nil
    ) {
        self.version = version
        self.encodingMode = encodingMode
        self.errorCorrectionLevel = errorCorrectionLevel
        self.mask = mask
    }
}
