//
//  QRErrorCorrectionLevel.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

// swift-format-ignore: AlwaysUseLowerCamelCase
public enum QRErrorCorrectionLevel: CaseIterable, Hashable, Sendable {
    case L
    case M
    case Q
    case H

    public static let min: QRErrorCorrectionLevel = .L
    public static let `default`: QRErrorCorrectionLevel = .M
    public static let max: QRErrorCorrectionLevel = .H

    static let descendingOrder: [QRErrorCorrectionLevel] = [
        .H, .Q, .M, .L,
    ]

    var formatIndicator: UInt32 {
        switch self {
        case .L: 0b01
        case .M: 0b00
        case .Q: 0b11
        case .H: 0b10
        }
    }
}
