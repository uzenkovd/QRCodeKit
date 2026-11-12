//
//  QRSymbol.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.10.2026.
//

/// A finalized QR code matrix: masked, with format
/// and version information in place.
struct QRSymbol: Equatable {
    let matrix: QRMatrix
    let mask: QRMask

    var size: Int {
        matrix.size
    }
}
