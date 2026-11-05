//
//  ANSITextLineTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 31.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct ANSITextLineTests {
    // MARK: - Color Changes

    @Test
    func emitsColorOnlyWhenItChanges() {
        var line = ANSITextLine()

        line.append("  ", background: .module(.light))
        line.append("  ", background: .module(.light))
        line.append("  ", background: .module(.dark))

        let expected =
            Self.sgr("48;5;231") + "    "
            + Self.sgr("48;5;16") + "  "
            + Self.reset

        #expect(line.string == expected)
    }

    @Test
    func combinesForegroundAndBackgroundChanges() {
        var line = ANSITextLine()

        line.append("▄", foreground: .dark, background: .module(.light))

        let expected =
            Self.sgr("38;5;16;48;5;231") + "▄"
            + Self.reset

        #expect(line.string == expected)
    }

    @Test
    func keepsForegroundWhenNotSpecified() {
        var line = ANSITextLine()

        line.append("▄", foreground: .dark, background: .module(.light))
        line.append(" ", background: .module(.dark))
        line.append("▄", foreground: .dark, background: .module(.light))

        // The space changes only the background, and the last glyph
        // reuses the dark foreground set by the first one.
        let expected =
            Self.sgr("38;5;16;48;5;231") + "▄"
            + Self.sgr("48;5;16") + " "
            + Self.sgr("48;5;231") + "▄"
            + Self.reset

        #expect(line.string == expected)
    }

    // MARK: - Terminal Background

    @Test
    func usesTerminalBackground() {
        var line = ANSITextLine()

        line.append("▀", foreground: .dark, background: .terminal)

        let expected =
            Self.sgr("38;5;16;49") + "▀"
            + Self.reset

        #expect(line.string == expected)
    }
}

// MARK: - Escape Sequence Support

private extension ANSITextLineTests {
    static let reset = "\u{1B}[0m"

    /// Builds a Select Graphic Rendition sequence: `ESC [ parameters m`.
    static func sgr(
        _ parameters: String
    ) -> String {
        "\u{1B}[\(parameters)m"
    }
}
