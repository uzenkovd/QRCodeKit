//
//  QRModule.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.09.2026.
//

enum QRModuleColor: Equatable {
    case light
    case dark
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
}
