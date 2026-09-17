//
//  QRCodeError.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum QRCodeError: Error, Sendable, Equatable {
    case emptyMessage
    case unsupportedMessage
    case messageIsTooLong

    case wrongEncodingModeForMessage
    case messageDoesNotFitEncodingMode

    case messageDoesNotFitVersion
    case messageDoesNotFitErrorCorrectionLevel
    case messageDoesNotFitQRConfiguration
}
