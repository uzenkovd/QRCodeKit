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

enum QRModule: Equatable {
    case unset
    case reserved(QRInformationType)
    case function(
        pattern: QRFunctionPattern,
        color: QRModuleColor
    )
    case darkModule
    case information(
        type: QRInformationType,
        color: QRModuleColor
    )
    case data(color: QRModuleColor)

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
