//
//  QRTextRendererANSIStyleTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 05.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRTextRendererANSIStyleTests {
    @Test
    func encodesRegularLine() {
        let line = QRTextRenderer.ansiRegularLine(
            [.light, .light, .dark]
        )

        // The second light module repeats the color, so no escape
        // sequence is emitted before it.
        let expected =
            Self.sgr("48;5;231") + "    "
            + Self.sgr("48;5;16") + "  "
            + Self.reset

        #expect(line == expected)
    }

    @Test
    func encodesCompactLine() {
        let line = QRTextRenderer.ansiCompactLine([
            (upper: .light, lower: .light),
            (upper: .light, lower: .dark),
            (upper: .dark, lower: .light),
            (upper: .dark, lower: .dark),
            (upper: .light, lower: nil),
            (upper: .dark, lower: nil)
        ])

        // Uniform cells are spaces and mixed cells are lower half
        // blocks. Without a lower half, light fills the cell, while
        // dark draws only the upper half over the terminal background.
        let expected =
            Self.sgr("48;5;231") + " "
            + Self.sgr("38;5;16") + "▄"
            + Self.sgr("38;5;231;48;5;16") + "▄"
            + " "
            + Self.sgr("48;5;231") + " "
            + Self.sgr("38;5;16;49") + "▀"
            + Self.reset

        #expect(line == expected)
    }
}

// MARK: - Escape Sequence Support

private extension QRTextRendererANSIStyleTests {
    static let reset = "\u{1B}[0m"

    /// Builds a Select Graphic Rendition sequence: `ESC [ parameters m`.
    static func sgr(
        _ parameters: String
    ) -> String {
        "\u{1B}[\(parameters)m"
    }
}
