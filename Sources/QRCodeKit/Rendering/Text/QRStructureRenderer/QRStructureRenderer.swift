//
//  QRStructureRenderer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.10.2026.
//

/// Renders the structure of a QR code as text: one character per module,
/// showing which part of the symbol the module belongs to.
///
/// The output is a diagnostic view and cannot be scanned.
enum QRStructureRenderer {
    /// Returns a header, the modules with row and column numbers,
    /// and a legend, separated by blank lines.
    ///
    /// Modules are shown as letters for the part of the symbol they
    /// belong to, uppercase when dark and lowercase when light.
    /// Modules of data and error correction codewords are `1` when dark
    /// and `0` when light.
    static func render(
        _ qrCode: QRCode
    ) -> String {
        [
            header(for: qrCode),
            render(qrCode.matrix),
            plainLegend
        ].joined(separator: "\n\n")
    }
}

// MARK: - Header

private extension QRStructureRenderer {
    static func header(
        for qrCode: QRCode
    ) -> String {
        let version = qrCode.version.rawValue
        let level = qrCode.errorCorrectionLevel
        let mask = qrCode.mask.rawValue
        let mode = qrCode.encodingMode
        let size = qrCode.size

        return "Version \(version)-\(level), \(mode) mode, "
            + "mask \(mask), \(size)×\(size) modules"
    }
}

// MARK: - Matrix Rendering

extension QRStructureRenderer {
    /// Renders the modules of a matrix at any stage of generation,
    /// without the header and the legend.
    ///
    /// Unfinished matrices may contain reserved modules, shown as `R`,
    /// and unset modules, shown as `?`.
    static func render(
        _ matrix: QRMatrix
    ) -> String {
        plainGrid(of: matrix)
    }

    static func modules(
        inRow row: Int,
        of matrix: QRMatrix
    ) -> [QRModule] {
        (0..<matrix.size).map { column in
            matrix[row, column]
        }
    }
}
