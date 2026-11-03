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
            return renderDebug(matrix)

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

// MARK: - Rendering Defaults

extension QRTextRenderer {
    static let defaultQuietZoneWidth = 4
}
