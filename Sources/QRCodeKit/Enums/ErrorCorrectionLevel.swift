//
//  ErrorCorrectionLevel.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum ErrorCorrectionLevel: Int, Sendable {
    case L = 7
    case M = 15
    case Q = 25
    case H = 30
    
    public static let min: ErrorCorrectionLevel = .L
    public static let `default`: ErrorCorrectionLevel = .M
    public static let max: ErrorCorrectionLevel = .H
}
