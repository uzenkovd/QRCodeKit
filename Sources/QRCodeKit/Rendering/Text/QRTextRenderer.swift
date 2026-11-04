//
//  QRTextRenderer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.10.2026.
//

public enum QRTextRenderer {
    public enum Mode: Sendable {
        case debug
        case blocks
        case compact
    }

    public static func render(
        _ qrCode: QRCode,
        mode: Mode
    ) -> String {
        render(qrCode.matrix, mode: mode)
    }
}

// MARK: - Matrix Rendering

extension QRTextRenderer {
    static func render(
        _ matrix: QRMatrix,
        mode: Mode
    ) -> String {
        switch mode {
        case .debug:
            return QRStructureRenderer.render(matrix)

        case .blocks:
            return renderBlocks(grid(for: matrix))

        case .compact:
            return renderCompact(grid(for: matrix))
        }
    }

    private static func grid(
        for matrix: QRMatrix
    ) -> QRRenderGrid {
        QRRenderGrid(
            matrix: matrix,
            quietZoneWidth: defaultQuietZoneWidth
        )
    }
}

// MARK: - Mode Rendering

extension QRTextRenderer {
    static func renderBlocks(
        _ grid: QRRenderGrid
    ) -> String {
        regularLines(of: grid)
            .map(plainRegularLine)
            .joined(separator: "\n")
    }

    static func renderCompact(
        _ grid: QRRenderGrid
    ) -> String {
        compactLines(of: grid)
            .map(plainCompactLine)
            .joined(separator: "\n")
    }

    static func renderANSIRegular(
        _ grid: QRRenderGrid
    ) -> String {
        regularLines(of: grid)
            .map(ansiRegularLine)
            .joined(separator: "\n")
    }

    static func renderANSICompact(
        _ grid: QRRenderGrid
    ) -> String {
        compactLines(of: grid)
            .map(ansiCompactLine)
            .joined(separator: "\n")
    }
}

// MARK: - Rendering Defaults

extension QRTextRenderer {
    static let defaultQuietZoneWidth = 4
}
