//
//  QRRenderGrid.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.10.2026.
//

/// A finalized QR symbol surrounded by a quiet zone,
/// viewed as a square grid of dark and light modules.
///
/// Coordinates include the quiet zone: `(0, 0)` is the top-left
/// corner of the quiet zone, not of the symbol.
struct QRRenderGrid {
    let size: Int

    private let matrix: QRMatrix
    private let quietZoneWidth: Int

    init(
        matrix: QRMatrix,
        quietZoneWidth: Int
    ) {
        precondition(
            quietZoneWidth >= 0,
            "Quiet zone width must be nonnegative"
        )

        self.matrix = matrix
        self.quietZoneWidth = quietZoneWidth
        self.size = matrix.size + quietZoneWidth * 2
    }

    subscript(
        row: Int,
        column: Int
    ) -> QRModuleColor {
        let gridRange = 0..<size

        precondition(
            gridRange.contains(row) && gridRange.contains(column),
            "Grid coordinates are out of bounds"
        )

        let matrixRow = row - quietZoneWidth
        let matrixColumn = column - quietZoneWidth
        let matrixRange = 0..<matrix.size

        guard
            matrixRange.contains(matrixRow),
            matrixRange.contains(matrixColumn)
        else {
            return .light
        }

        return Self.color(of: matrix[matrixRow, matrixColumn])
    }
}

// MARK: - Module Resolution

private extension QRRenderGrid {
    static func color(
        of module: QRModule
    ) -> QRModuleColor {
        switch module {
        case .data(color: .light),
             .function(pattern: _, color: .light),
             .information(type: _, color: .light):
            return .light

        case .data(color: .dark),
             .function(pattern: _, color: .dark),
             .information(type: _, color: .dark),
             .darkModule:
            return .dark

        case .reserved, .unset:
            preconditionFailure(
                "Only finalized matrices can be rendered"
            )
        }
    }
}
