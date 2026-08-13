//
//  QRCodeError.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum QRCodeError: Error, Sendable {
    case emptyMessage
    case unsupportedMessage
    case noAppropriateEncodingMode
}
