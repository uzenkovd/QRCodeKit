//
//  QROptions.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public struct QROptions {
    public var version: QRVersion?
    public var encodingMode: EncodingMode?
    public var errorCorrectionLevel: ErrorCorrectionLevel?
    public var mask: QRMask?
    
    public init(
        version: QRVersion? = nil,
        encodingMode: EncodingMode? = nil,
        errorCorrectionLevel: ErrorCorrectionLevel? = nil,
        mask: QRMask? = nil
    ) {
        self.version = version
        self.encodingMode = encodingMode
        self.errorCorrectionLevel = errorCorrectionLevel
        self.mask = mask
    }
}
