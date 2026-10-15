//
//  QRSymbol.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.10.2026.
//

struct QRSymbol {
    let matrix: QRMatrix
    let mask: QRMask

    var size: Int {
        matrix.size
    }
}
