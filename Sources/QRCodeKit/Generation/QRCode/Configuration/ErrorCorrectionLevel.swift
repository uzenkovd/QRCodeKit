//
//  ErrorCorrectionLevel.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum ErrorCorrectionLevel: Sendable, CaseIterable, Hashable {
    case L
    case M
    case Q
    case H

    static let descendingOrder: [ErrorCorrectionLevel] = [
        .H, .Q, .M, .L
    ]

    public static let min: ErrorCorrectionLevel = .L
    public static let `default`: ErrorCorrectionLevel = .M
    public static let max: ErrorCorrectionLevel = .H

    var formatIndicator: UInt32 {
        switch self {
        case .L: 0b01
        case .M: 0b00
        case .Q: 0b11
        case .H: 0b10
        }
    }
}
