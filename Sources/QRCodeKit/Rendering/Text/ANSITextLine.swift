//
//  ANSITextLine.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 31.10.2026.
//

/// A line of text colored with ANSI escape sequences.
///
/// A color is emitted only when it changes, and the line ends
/// with a reset, so colors never leak past the end of the line.
struct ANSITextLine {
    enum Background: Equatable {
        case module(QRModuleColor)
        case terminal
    }

    private var text = String()
    private var foreground: QRModuleColor?
    private var background: Background?

    /// The line terminated with a reset of all attributes.
    var string: String {
        text + Self.reset
    }

    /// Appends text drawn in the given colors.
    ///
    /// A `nil` foreground keeps the current one, which suits text
    /// that draws no foreground pixels, such as spaces.
    mutating func append(
        _ glyphs: String,
        foreground newForeground: QRModuleColor? = nil,
        background newBackground: Background
    ) {
        var parameters: [String] = []

        if let newForeground, newForeground != foreground {
            parameters.append(Self.foregroundParameter(for: newForeground))
            foreground = newForeground
        }

        if newBackground != background {
            parameters.append(Self.backgroundParameter(for: newBackground))
            background = newBackground
        }

        if !parameters.isEmpty {
            text += Self.escape + parameters.joined(separator: ";") + "m"
        }

        text += glyphs
    }
}

// MARK: - Escape Sequences

private extension ANSITextLine {
    static let escape = "\u{1B}["
    static let reset = "\u{1B}[0m"

    static func foregroundParameter(
        for color: QRModuleColor
    ) -> String {
        "38;5;\(paletteIndex(of: color))"
    }

    static func backgroundParameter(
        for background: Background
    ) -> String {
        switch background {
        case .module(let color): "48;5;\(paletteIndex(of: color))"
        case .terminal: "49"
        }
    }

    /// Exact black and white from the 256-color palette,
    /// which terminal themes do not recolor.
    static func paletteIndex(
        of color: QRModuleColor
    ) -> Int {
        switch color {
        case .light: 231
        case .dark: 16
        }
    }
}
