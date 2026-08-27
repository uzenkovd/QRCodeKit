//
//  QRCodeError.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum QRCodeError: Error, Sendable, Equatable {
    case emptyMessage
    case messageIsTooLong
    case unsupportedMessage
    
    case wrongEncodingModeForMessage
    
    case messageDoesNotFitVersion
    case messageDoesNotFitErrorCorrectionLevel
    case messageDoesNotFitQRConfiguration
}
