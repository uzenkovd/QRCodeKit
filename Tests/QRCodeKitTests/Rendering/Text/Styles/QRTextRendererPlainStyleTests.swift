//
//  QRTextRendererPlainStyleTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 05.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererPlainStyleTests {
    @Test
    func encodesRegularLine() {
        let line = QRTextRenderer.plainRegularLine(
            [.light, .dark, .dark]
        )

        #expect(line == "██░░░░")
    }

    @Test
    func encodesCompactLine() {
        let line = QRTextRenderer.plainCompactLine([
            (upper: .light, lower: .light),
            (upper: .light, lower: .dark),
            (upper: .dark, lower: .light),
            (upper: .dark, lower: .dark),
            (upper: .light, lower: nil),
            (upper: .dark, lower: nil)
        ])

        #expect(line == "█▀▄ ▀ ")
    }
}
