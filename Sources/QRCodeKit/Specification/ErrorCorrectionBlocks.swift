//
//  ErrorCorrectionBlocks.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 23.08.2026.
//

enum ErrorCorrectionBlocks {
    struct Group {
        let blockCount: Int
        let dataCodewordsPerBlock: Int
        
        init(_ blockCount: Int, _ dataCodewordsPerBlock: Int) {
            self.blockCount = blockCount
            self.dataCodewordsPerBlock = dataCodewordsPerBlock
        }
        
        var totalDataCodewords: Int {
            blockCount * dataCodewordsPerBlock
        }
    }
    
    struct Layout {
        let errorCorrectionCodewordsPerBlock: Int
        let group1: Group
        let group2: Group?
        
        init(
            _ errorCorrectionCodewordsPerBlock: Int,
            _ group1: Group,
            _ group2: Group? = nil
        ) {
            self.errorCorrectionCodewordsPerBlock = errorCorrectionCodewordsPerBlock
            self.group1 = group1
            self.group2 = group2
        }
        
        var totalBlockCount: Int {
            group1.blockCount + (group2?.blockCount ?? 0)
        }
        
        var totalDataCodewords: Int {
            group1.totalDataCodewords + (group2?.totalDataCodewords ?? 0)
        }
        
        var totalErrorCorrectionCodewords: Int {
            totalBlockCount * errorCorrectionCodewordsPerBlock
        }
        
        var totalCodewords: Int {
            totalDataCodewords + totalErrorCorrectionCodewords
        }
    }
    
    static func totalDataCodewords(
        for version: QRVersion,
        level: ErrorCorrectionLevel
    ) -> Int {
        layout(for: version, level: level).totalDataCodewords
    }
    
    static func layout(
        for version: QRVersion,
        level: ErrorCorrectionLevel
    ) -> Layout {
        guard let layout = table[version]?[level] else {
            preconditionFailure(
                "Error correction block layout is missing for \(version) and \(level)"
            )
        }
        
        return layout
    }
}

private extension ErrorCorrectionBlocks {
    static let table: [QRVersion: [ErrorCorrectionLevel: Layout]] = [
        .v1: [
            .L: Layout(7, Group(1, 19)),
            .M: Layout(10, Group(1, 16)),
            .Q: Layout(13, Group(1, 13)),
            .H: Layout(17, Group(1, 9))
        ],
        .v2: [
            .L: Layout(10, Group(1, 34)),
            .M: Layout(16, Group(1, 28)),
            .Q: Layout(22, Group(1, 22)),
            .H: Layout(28, Group(1, 16))
        ],
        .v3: [
            .L: Layout(15, Group(1, 55)),
            .M: Layout(26, Group(1, 44)),
            .Q: Layout(18, Group(2, 17)),
            .H: Layout(22, Group(2, 13))
        ],
        .v4: [
            .L: Layout(20, Group(1, 80)),
            .M: Layout(18, Group(2, 32)),
            .Q: Layout(26, Group(2, 24)),
            .H: Layout(16, Group(4, 9))
        ],
        .v5: [
            .L: Layout(26, Group(1, 108)),
            .M: Layout(24, Group(2, 43)),
            .Q: Layout(18, Group(2, 15), Group(2, 16)),
            .H: Layout(22, Group(2, 11), Group(2, 12))
        ],
        .v6: [
            .L: Layout(18, Group(2, 68)),
            .M: Layout(16, Group(4, 27)),
            .Q: Layout(24, Group(4, 19)),
            .H: Layout(28, Group(4, 15))
        ],
        .v7: [
            .L: Layout(20, Group(2, 78)),
            .M: Layout(18, Group(4, 31)),
            .Q: Layout(18, Group(2, 14), Group(4, 15)),
            .H: Layout(26, Group(4, 13), Group(1, 14))
        ],
        .v8: [
            .L: Layout(24, Group(2, 97)),
            .M: Layout(22, Group(2, 38), Group(2, 39)),
            .Q: Layout(22, Group(4, 18), Group(2, 19)),
            .H: Layout(26, Group(4, 14), Group(2, 15))
        ],
        .v9: [
            .L: Layout(30, Group(2, 116)),
            .M: Layout(22, Group(3, 36), Group(2, 37)),
            .Q: Layout(20, Group(4, 16), Group(4, 17)),
            .H: Layout(24, Group(4, 12), Group(4, 13))
        ],
        .v10: [
            .L: Layout(18, Group(2, 68), Group(2, 69)),
            .M: Layout(26, Group(4, 43), Group(1, 44)),
            .Q: Layout(24, Group(6, 19), Group(2, 20)),
            .H: Layout(28, Group(6, 15), Group(2, 16))
        ],
        .v11: [
            .L: Layout(20, Group(4, 81)),
            .M: Layout(30, Group(1, 50), Group(4, 51)),
            .Q: Layout(28, Group(4, 22), Group(4, 23)),
            .H: Layout(24, Group(3, 12), Group(8, 13))
        ],
        .v12: [
            .L: Layout(24, Group(2, 92), Group(2, 93)),
            .M: Layout(22, Group(6, 36), Group(2, 37)),
            .Q: Layout(26, Group(4, 20), Group(6, 21)),
            .H: Layout(28, Group(7, 14), Group(4, 15))
        ],
        .v13: [
            .L: Layout(26, Group(4, 107)),
            .M: Layout(22, Group(8, 37), Group(1, 38)),
            .Q: Layout(24, Group(8, 20), Group(4, 21)),
            .H: Layout(22, Group(12, 11), Group(4, 12))
        ],
        .v14: [
            .L: Layout(30, Group(3, 115), Group(1, 116)),
            .M: Layout(24, Group(4, 40), Group(5, 41)),
            .Q: Layout(20, Group(11, 16), Group(5, 17)),
            .H: Layout(24, Group(11, 12), Group(5, 13))
        ],
        .v15: [
            .L: Layout(22, Group(5, 87), Group(1, 88)),
            .M: Layout(24, Group(5, 41), Group(5, 42)),
            .Q: Layout(30, Group(5, 24), Group(7, 25)),
            .H: Layout(24, Group(11, 12), Group(7, 13))
        ],
        .v16: [
            .L: Layout(24, Group(5, 98), Group(1, 99)),
            .M: Layout(28, Group(7, 45), Group(3, 46)),
            .Q: Layout(24, Group(15, 19), Group(2, 20)),
            .H: Layout(30, Group(3, 15), Group(13, 16))
        ],
        .v17: [
            .L: Layout(28, Group(1, 107), Group(5, 108)),
            .M: Layout(28, Group(10, 46), Group(1, 47)),
            .Q: Layout(28, Group(1, 22), Group(15, 23)),
            .H: Layout(28, Group(2, 14), Group(17, 15))
        ],
        .v18: [
            .L: Layout(30, Group(5, 120), Group(1, 121)),
            .M: Layout(26, Group(9, 43), Group(4, 44)),
            .Q: Layout(28, Group(17, 22), Group(1, 23)),
            .H: Layout(28, Group(2, 14), Group(19, 15))
        ],
        .v19: [
            .L: Layout(28, Group(3, 113), Group(4, 114)),
            .M: Layout(26, Group(3, 44), Group(11, 45)),
            .Q: Layout(26, Group(17, 21), Group(4, 22)),
            .H: Layout(26, Group(9, 13), Group(16, 14))
        ],
        .v20: [
            .L: Layout(28, Group(3, 107), Group(5, 108)),
            .M: Layout(26, Group(3, 41), Group(13, 42)),
            .Q: Layout(30, Group(15, 24), Group(5, 25)),
            .H: Layout(28, Group(15, 15), Group(10, 16))
        ],
        .v21: [
            .L: Layout(28, Group(4, 116), Group(4, 117)),
            .M: Layout(26, Group(17, 42)),
            .Q: Layout(28, Group(17, 22), Group(6, 23)),
            .H: Layout(30, Group(19, 16), Group(6, 17))
        ],
        .v22: [
            .L: Layout(28, Group(2, 111), Group(7, 112)),
            .M: Layout(28, Group(17, 46)),
            .Q: Layout(30, Group(7, 24), Group(16, 25)),
            .H: Layout(24, Group(34, 13))
        ],
        .v23: [
            .L: Layout(30, Group(4, 121), Group(5, 122)),
            .M: Layout(28, Group(4, 47), Group(14, 48)),
            .Q: Layout(30, Group(11, 24), Group(14, 25)),
            .H: Layout(30, Group(16, 15), Group(14, 16))
        ],
        .v24: [
            .L: Layout(30, Group(6, 117), Group(4, 118)),
            .M: Layout(28, Group(6, 45), Group(14, 46)),
            .Q: Layout(30, Group(11, 24), Group(16, 25)),
            .H: Layout(30, Group(30, 16), Group(2, 17))
        ],
        .v25: [
            .L: Layout(26, Group(8, 106), Group(4, 107)),
            .M: Layout(28, Group(8, 47), Group(13, 48)),
            .Q: Layout(30, Group(7, 24), Group(22, 25)),
            .H: Layout(30, Group(22, 15), Group(13, 16))
        ],
        .v26: [
            .L: Layout(28, Group(10, 114), Group(2, 115)),
            .M: Layout(28, Group(19, 46), Group(4, 47)),
            .Q: Layout(28, Group(28, 22), Group(6, 23)),
            .H: Layout(30, Group(33, 16), Group(4, 17))
        ],
        .v27: [
            .L: Layout(30, Group(8, 122), Group(4, 123)),
            .M: Layout(28, Group(22, 45), Group(3, 46)),
            .Q: Layout(30, Group(8, 23), Group(26, 24)),
            .H: Layout(30, Group(12, 15), Group(28, 16))
        ],
        .v28: [
            .L: Layout(30, Group(3, 117), Group(10, 118)),
            .M: Layout(28, Group(3, 45), Group(23, 46)),
            .Q: Layout(30, Group(4, 24), Group(31, 25)),
            .H: Layout(30, Group(11, 15), Group(31, 16))
        ],
        .v29: [
            .L: Layout(30, Group(7, 116), Group(7, 117)),
            .M: Layout(28, Group(21, 45), Group(7, 46)),
            .Q: Layout(30, Group(1, 23), Group(37, 24)),
            .H: Layout(30, Group(19, 15), Group(26, 16))
        ],
        .v30: [
            .L: Layout(30, Group(5, 115), Group(10, 116)),
            .M: Layout(28, Group(19, 47), Group(10, 48)),
            .Q: Layout(30, Group(15, 24), Group(25, 25)),
            .H: Layout(30, Group(23, 15), Group(25, 16))
        ],
        .v31: [
            .L: Layout(30, Group(13, 115), Group(3, 116)),
            .M: Layout(28, Group(2, 46), Group(29, 47)),
            .Q: Layout(30, Group(42, 24), Group(1, 25)),
            .H: Layout(30, Group(23, 15), Group(28, 16))
        ],
        .v32: [
            .L: Layout(30, Group(17, 115)),
            .M: Layout(28, Group(10, 46), Group(23, 47)),
            .Q: Layout(30, Group(10, 24), Group(35, 25)),
            .H: Layout(30, Group(19, 15), Group(35, 16))
        ],
        .v33: [
            .L: Layout(30, Group(17, 115), Group(1, 116)),
            .M: Layout(28, Group(14, 46), Group(21, 47)),
            .Q: Layout(30, Group(29, 24), Group(19, 25)),
            .H: Layout(30, Group(11, 15), Group(46, 16))
        ],
        .v34: [
            .L: Layout(30, Group(13, 115), Group(6, 116)),
            .M: Layout(28, Group(14, 46), Group(23, 47)),
            .Q: Layout(30, Group(44, 24), Group(7, 25)),
            .H: Layout(30, Group(59, 16), Group(1, 17))
        ],
        .v35: [
            .L: Layout(30, Group(12, 121), Group(7, 122)),
            .M: Layout(28, Group(12, 47), Group(26, 48)),
            .Q: Layout(30, Group(39, 24), Group(14, 25)),
            .H: Layout(30, Group(22, 15), Group(41, 16))
        ],
        .v36: [
            .L: Layout(30, Group(6, 121), Group(14, 122)),
            .M: Layout(28, Group(6, 47), Group(34, 48)),
            .Q: Layout(30, Group(46, 24), Group(10, 25)),
            .H: Layout(30, Group(2, 15), Group(64, 16))
        ],
        .v37: [
            .L: Layout(30, Group(17, 122), Group(4, 123)),
            .M: Layout(28, Group(29, 46), Group(14, 47)),
            .Q: Layout(30, Group(49, 24), Group(10, 25)),
            .H: Layout(30, Group(24, 15), Group(46, 16))
        ],
        .v38: [
            .L: Layout(30, Group(4, 122), Group(18, 123)),
            .M: Layout(28, Group(13, 46), Group(32, 47)),
            .Q: Layout(30, Group(48, 24), Group(14, 25)),
            .H: Layout(30, Group(42, 15), Group(32, 16))
        ],
        .v39: [
            .L: Layout(30, Group(20, 117), Group(4, 118)),
            .M: Layout(28, Group(40, 47), Group(7, 48)),
            .Q: Layout(30, Group(43, 24), Group(22, 25)),
            .H: Layout(30, Group(10, 15), Group(67, 16))
        ],
        .v40: [
            .L: Layout(30, Group(19, 118), Group(6, 119)),
            .M: Layout(28, Group(18, 47), Group(31, 48)),
            .Q: Layout(30, Group(34, 24), Group(34, 25)),
            .H: Layout(30, Group(20, 15), Group(61, 16))
        ]
    ]
}
