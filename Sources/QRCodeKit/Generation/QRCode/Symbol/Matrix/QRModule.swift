//
//  QRModule.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.09.2026.
//

enum QRModuleColor: Equatable {
    case light
    case dark

    var inverted: QRModuleColor {
        switch self {
        case .light: .dark
        case .dark: .light
        }
    }
}

enum QRFunctionPattern: Equatable {
    case finder
    case separator
    case alignment
    case timing
}

enum QRInformationType: Equatable {
    case format
    case version
}

/// A single module of a matrix: the part of the symbol
/// it belongs to and, once known, its color.
enum QRModule: Equatable {
    /// Not filled in yet.
    case unset

    /// Kept free for format or version information,
    /// which is placed when the symbol is finalized.
    case reserved(QRInformationType)

    /// Part of a finder, separator, alignment or timing pattern.
    case function(
        pattern: QRFunctionPattern,
        color: QRModuleColor
    )

    /// The module next to the bottom-left finder pattern
    /// that is dark in every symbol.
    case darkModule

    /// Part of the format or version information.
    case information(
        type: QRInformationType,
        color: QRModuleColor
    )

    /// A bit of the encoded data: message, error correction
    /// or remainder bits.
    case data(color: QRModuleColor)

    /// The color of the module, or `nil` while it is unset or still reserved.
    var color: QRModuleColor? {
        switch self {
        case let .function(_, color),
             let .information(_, color),
             let .data(color):
            return color

        case .darkModule:
            return .dark

        case .unset, .reserved:
            return nil
        }
    }
}
