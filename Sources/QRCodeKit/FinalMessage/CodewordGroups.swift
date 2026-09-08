//
//  CodewordGroups.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.09.2026.
//

struct CodewordGroups {
    let group1: Group
    let group2: Group?

    var blockCount: Int {
        group1.blockCount + (group2?.blockCount ?? 0)
    }

    var totalDataCodewordCount: Int {
        group1.totalDataCodewordCount
            + (group2?.totalDataCodewordCount ?? 0)
    }

    var totalErrorCorrectionCodewordCount: Int {
        group1.totalErrorCorrectionCodewordCount
            + (group2?.totalErrorCorrectionCodewordCount ?? 0)
    }

    var totalCodewordCount: Int {
        totalDataCodewordCount + totalErrorCorrectionCodewordCount
    }

    init(
        group1: Group,
        group2: Group?
    ) {
        if let group2 {
            precondition(
                group2.dataCodewordCountPerBlock
                    == group1.dataCodewordCountPerBlock + 1,
                "Group 2 must contain one more data codeword per block than Group 1"
            )
            precondition(
                group2.errorCorrectionCodewordCountPerBlock
                    == group1.errorCorrectionCodewordCountPerBlock,
                "Both groups must have the same error correction codeword count per block"
            )
        }

        self.group1 = group1
        self.group2 = group2
    }
}
