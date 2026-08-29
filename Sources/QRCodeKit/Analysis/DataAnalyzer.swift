//
//  DataAnalyzer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.08.2026.
//

struct DataAnalyzer {
    func canEncode(_ message: String) -> Bool {
        EncodingMode.allCases.contains {
            $0.canEncode(message)
        }
    }
    
    func canFit(
        _ characterCount: Int,
        mode: EncodingMode
    ) -> Bool {
        let maxCapacity = CharacterCapacities.maxCapacity(for: mode)
        
        return characterCount <= maxCapacity
    }
    
    func canFit(
        _ characterCount: Int,
        mode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel,
        version: QRVersion
    ) -> Bool {
        let capacity = CharacterCapacities.capacity(
            for: version,
            level: errorCorrectionLevel,
            mode: mode
        )
        
        return characterCount <= capacity
    }
    
    func recommendedEncodingMode(for message: String) -> EncodingMode? {
        for mode in EncodingMode.recommendedOrder {
            if mode.canEncode(message) {
                return mode
            }
        }
        
        return nil
    }
    
    func recommendedVersion(
        for characterCount: Int,
        mode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> QRVersion? {
        for version in QRVersion.allCases {
            let capacity = CharacterCapacities.capacity(
                for: version,
                level: errorCorrectionLevel,
                mode: mode
            )
            
            if characterCount <= capacity {
                return version
            }
        }
        
        return nil
    }
    
    func recommendedErrorCorrectionLevel(
        for characterCount: Int,
        mode: EncodingMode,
        version: QRVersion
    ) -> ErrorCorrectionLevel? {
        for level in ErrorCorrectionLevel.descendingOrder {
            if canFit(
                characterCount,
                mode: mode,
                errorCorrectionLevel: level,
                version: version
            ) {
                return level
            }
        }
        
        return nil
    }
}
