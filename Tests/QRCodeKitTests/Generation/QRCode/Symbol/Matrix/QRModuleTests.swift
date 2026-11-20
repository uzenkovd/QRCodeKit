//
//  QRModuleTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRModuleTests {
    // MARK: - Module

    @Test(arguments: [
        (.function(pattern: .finder, color: .dark), .dark),
        (.function(pattern: .timing, color: .light), .light),
        (.darkModule, .dark),
        (.information(type: .format, color: .dark), .dark),
        (.information(type: .version, color: .light), .light),
        (.data(color: .dark), .dark),
        (.data(color: .light), .light)
    ] as [(QRModule, QRModuleColor)])
    func hasColorOnceFilledIn(
        module: QRModule,
        expectedColor: QRModuleColor
    ) {
        #expect(module.color == expectedColor)
    }

    @Test(arguments: [
        .unset,
        .reserved(.format),
        .reserved(.version)
    ] as [QRModule])
    func hasNoColorUntilFilledIn(
        module: QRModule
    ) {
        #expect(module.color == nil)
    }

    // MARK: - Module Color

    @Test(arguments: [
        (.light, .dark),
        (.dark, .light)
    ] as [(QRModuleColor, QRModuleColor)])
    func invertsColor(
        color: QRModuleColor,
        expectedColor: QRModuleColor
    ) {
        #expect(color.inverted == expectedColor)
    }
}
