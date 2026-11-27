//
//  QRTextRenderer+CompactLayout.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 02.11.2026.
//

extension QRTextRenderer {
    typealias CompactCellColors = (
        upper: QRModuleColor,
        lower: QRModuleColor?
    )

    /// Splits the grid into text lines that pair two grid rows,
    /// so each cell holds a module and the module below it.
    ///
    /// The last row of an odd-height grid has no lower module.
    static func compactLines(
        of grid: QRRenderGrid
    ) -> [[CompactCellColors]] {
        stride(from: 0, to: grid.size, by: 2).map { upperRow -> [CompactCellColors] in
            let lowerRow = upperRow + 1

            return (0..<grid.size).map { column -> CompactCellColors in
                (
                    upper: grid[upperRow, column],
                    lower: lowerRow < grid.size
                        ? grid[lowerRow, column]
                        : nil
                )
            }
        }
    }
}
