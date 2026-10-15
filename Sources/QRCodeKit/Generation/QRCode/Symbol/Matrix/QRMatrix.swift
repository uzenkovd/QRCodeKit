//
//  QRMatrix.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.09.2026.
//

struct QRMatrix: Equatable {
    let size: Int

    private var modules: [QRModule]

    init(version: QRVersion) {
        let size = version.size

        self.size = size
        modules = Array(
            repeating: .unset,
            count: size * size
        )
    }

    subscript(
        row: Int,
        column: Int
    ) -> QRModule {
        get {
            modules[index(row, column)]
        }
        set {
            modules[index(row, column)] = newValue
        }
    }
}

// MARK: - Indexing

private extension QRMatrix {
    func index(
        _ row: Int,
        _ column: Int
    ) -> Int {
        precondition(
            row >= 0 && row < size,
            "Row index is out of bounds"
        )
        precondition(
            column >= 0 && column < size,
            "Column index is out of bounds"
        )

        return row * size + column
    }
}
