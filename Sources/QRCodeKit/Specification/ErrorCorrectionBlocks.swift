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
}
