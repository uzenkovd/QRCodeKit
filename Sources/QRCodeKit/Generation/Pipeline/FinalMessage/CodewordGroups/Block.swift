//
//  Block.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 04.09.2026.
//

struct Block: Equatable {
    let dataCodewords: [UInt8]
    let errorCorrectionCodewords: [UInt8]

    var codewords: [UInt8] {
        dataCodewords + errorCorrectionCodewords
    }

    var dataCodewordCount: Int {
        dataCodewords.count
    }

    var errorCorrectionCodewordCount: Int {
        errorCorrectionCodewords.count
    }

    var codewordCount: Int {
        dataCodewordCount + errorCorrectionCodewordCount
    }

    init(
        dataCodewords: [UInt8],
        errorCorrectionCodewords: [UInt8]
    ) {
        precondition(
            !dataCodewords.isEmpty,
            "Block data codewords must not be empty"
        )
        precondition(
            !errorCorrectionCodewords.isEmpty,
            "Block error correction codewords must not be empty"
        )

        self.dataCodewords = dataCodewords
        self.errorCorrectionCodewords = errorCorrectionCodewords
    }
}
