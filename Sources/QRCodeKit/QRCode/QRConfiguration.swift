//
//  QRConfiguration.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.09.2026.
//

struct QRConfiguration {
    let version: QRVersion
    let encodingMode: EncodingMode
    let errorCorrectionLevel: ErrorCorrectionLevel

    var mask: QRMask?
}
