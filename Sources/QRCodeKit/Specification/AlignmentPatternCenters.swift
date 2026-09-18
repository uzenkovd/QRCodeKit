//
//  AlignmentPatternCenters.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.09.2026.
//

enum AlignmentPatternCenters {
    static func coordinates(
        for version: QRVersion
    ) -> [Int] {
        guard let coordinates = table[version] else {
            preconditionFailure(
                "Alignment pattern centers are missing for version \(version.rawValue)"
            )
        }

        return coordinates
    }
}

// MARK: - Specification Data

private extension AlignmentPatternCenters {
    static let table: [QRVersion: [Int]] = [
        .v1: [],
        .v2: [6, 18],
        .v3: [6, 22],
        .v4: [6, 26],
        .v5: [6, 30],
        .v6: [6, 34],
        .v7: [6, 22, 38],
        .v8: [6, 24, 42],
        .v9: [6, 26, 46],
        .v10: [6, 28, 50],
        .v11: [6, 30, 54],
        .v12: [6, 32, 58],
        .v13: [6, 34, 62],
        .v14: [6, 26, 46, 66],
        .v15: [6, 26, 48, 70],
        .v16: [6, 26, 50, 74],
        .v17: [6, 30, 54, 78],
        .v18: [6, 30, 56, 82],
        .v19: [6, 30, 58, 86],
        .v20: [6, 34, 62, 90],
        .v21: [6, 28, 50, 72, 94],
        .v22: [6, 26, 50, 74, 98],
        .v23: [6, 30, 54, 78, 102],
        .v24: [6, 28, 54, 80, 106],
        .v25: [6, 32, 58, 84, 110],
        .v26: [6, 30, 58, 86, 114],
        .v27: [6, 34, 62, 90, 118],
        .v28: [6, 26, 50, 74, 98, 122],
        .v29: [6, 30, 54, 78, 102, 126],
        .v30: [6, 26, 52, 78, 104, 130],
        .v31: [6, 30, 56, 82, 108, 134],
        .v32: [6, 34, 60, 86, 112, 138],
        .v33: [6, 30, 58, 86, 114, 142],
        .v34: [6, 34, 62, 90, 118, 146],
        .v35: [6, 30, 54, 78, 102, 126, 150],
        .v36: [6, 24, 50, 76, 102, 128, 154],
        .v37: [6, 28, 54, 80, 106, 132, 158],
        .v38: [6, 32, 58, 84, 110, 136, 162],
        .v39: [6, 26, 54, 82, 110, 138, 166],
        .v40: [6, 30, 58, 86, 114, 142, 170]
    ]
}
