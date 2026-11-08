//
//  QRTextRenderer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.10.2026.
//

/// Renders a QR code as text that can be scanned from a screen.
///
/// Choose a ``Layout`` and a ``Style`` to fit the destination.
public enum QRTextRenderer {
    /// How modules are arranged into lines of text.
    public enum Layout: CaseIterable, Sendable {
        /// One line per row of modules, two characters per module,
        /// so modules look roughly square.
        case regular

        /// One line per two rows of modules, one character per column.
        ///
        /// The output takes about a quarter of the space of ``regular``,
        /// but it relies on half block characters, which some terminals
        /// draw with small gaps.
        case compact
    }

    /// How modules are written as characters.
    public enum Style: CaseIterable, Sendable {
        /// Block characters without escape codes, for any destination
        /// that shows plain text.
        ///
        /// Light modules are drawn in the text color, so the colors
        /// of the code are correct only on a dark background.
        case plain

        /// ANSI escape codes that color every module, so the output
        /// does not depend on the terminal background.
        ///
        /// Use it only when writing to a terminal that supports 256 colors.
        /// Other destinations, such as files or chats, show escape codes as text.
        case ansi
    }

    /// The minimum quiet zone width the standard requires, in modules.
    public static let defaultQuietZoneWidth = 4

    /// Returns the text of a QR code, with lines separated by `\n`
    /// and no trailing newline.
    ///
    /// The default layout and style produce compact text without
    /// escape codes, so it can be written to any destination.
    ///
    /// - Parameters:
    ///   - qrCode: The QR code to render.
    ///   - layout: How modules are arranged into lines.
    ///   - style: How modules are written as characters.
    ///   - quietZoneWidth: The width of the light margin around
    ///     the symbol, in modules. The default is ``defaultQuietZoneWidth``.
    ///     Must not be negative.
    public static func render(
        _ qrCode: QRCode,
        layout: Layout = .compact,
        style: Style = .plain,
        quietZoneWidth: Int = defaultQuietZoneWidth
    ) -> String {
        let grid = QRRenderGrid(
            matrix: qrCode.matrix,
            quietZoneWidth: quietZoneWidth
        )

        return render(grid, layout: layout, style: style)
    }
}

// MARK: - Grid Rendering

extension QRTextRenderer {
    static func render(
        _ grid: QRRenderGrid,
        layout: Layout,
        style: Style
    ) -> String {
        let lines = switch (layout, style) {
        case (.regular, .plain): regularLines(of: grid).map(plainRegularLine)
        case (.compact, .plain): compactLines(of: grid).map(plainCompactLine)
        case (.regular, .ansi): regularLines(of: grid).map(ansiRegularLine)
        case (.compact, .ansi): compactLines(of: grid).map(ansiCompactLine)
        }

        return lines.joined(separator: "\n")
    }
}
