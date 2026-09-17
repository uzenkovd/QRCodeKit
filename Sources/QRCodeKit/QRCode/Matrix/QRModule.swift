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

enum QRStructuralRole: Equatable {
    case finderPattern
    case separator
    case alignmentPattern
    case timingPattern
    case darkModule
    case formatInformation
    case versionInformation
}

enum QRReservedArea: Equatable {
    case formatInformation
    case versionInformation
}

enum QRModule: Equatable {
    case unset
    case reserved(QRReservedArea)
    case structural(
        role: QRStructuralRole,
        color: QRModuleColor
    )
    case data(color: QRModuleColor)
}
