//
//  DataPlacer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 23.09.2026.
//

enum DataPlacer {
    static func place(
        _ bits: BitBuffer,
        in matrix: inout QRMatrix
    ) {
        let timingColumn = 6

        var bitIndex = 0
        var rightColumn = matrix.size - 1
        var row = matrix.size - 1
        var rowStep = -1

        while rightColumn > 0 {
            if rightColumn == timingColumn {
                rightColumn -= 1
            }

            while row >= 0 && row < matrix.size {
                for columnOffset in 0..<2 {
                    let column = rightColumn - columnOffset

                    switch matrix[row, column] {
                    case .unset:
                        precondition(
                            bitIndex < bits.count,
                            "Not enough bits to fill the data modules"
                        )

                        let bit = bits[bitIndex]
                        let color: QRModuleColor = bit ? .dark : .light

                        matrix[row, column] = .data(color: color)
                        bitIndex += 1

                    case .function, .reserved, .darkModule:
                        continue

                    case .data, .information:
                        preconditionFailure(
                            "Data can only be placed once and before information modules"
                        )
                    }
                }

                row += rowStep
            }

            rowStep = -rowStep
            row += rowStep
            rightColumn -= 2
        }

        precondition(
            bitIndex == bits.count,
            "Not all data bits were placed"
        )
    }
}
