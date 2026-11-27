//
//  QRTextRenderer+RegularLayout.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 02.11.2026.
//

extension QRTextRenderer {
    /// Splits the grid into text lines: one line per grid row
    /// and one cell per module.
    static func regularLines(
        of grid: QRRenderGrid
    ) -> [[QRModuleColor]] {
        (0..<grid.size).map { row in
            (0..<grid.size).map { column in
                grid[row, column]
            }
        }
    }
}
