//
//  DataAnalyzer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.08.2026.
//

struct DataAnalyzer {
    func canEncode(_ message: String) -> Bool {
        EncodingMode.allCases.contains { $0.canEncode(message) }
    }
    
    func canFit(
        characterCount: Int,
        encodingMode: EncodingMode
    ) -> Bool {
        let maxCapacity = CharacterCapacities.maxCapacity(for: encodingMode)
        
        return characterCount <= maxCapacity
    }
    
    func canFit(
        characterCount: Int,
        encodingMode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel,
        version: QRVersion
    ) -> Bool {
        let capacity = CharacterCapacities.capacity(
            version: version,
            errorCorrectionLevel: errorCorrectionLevel,
            encodingMode: encodingMode
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
        characterCount: Int,
        encodingMode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> QRVersion? {
        for version in QRVersion.allCases {
            let capacity = CharacterCapacities.capacity(
                version: version,
                errorCorrectionLevel: errorCorrectionLevel,
                encodingMode: encodingMode
            )
            
            if characterCount <= capacity {
                return version
            }
        }
        
        return nil
    }
    
    func maximizeErrorCorrectionLevel(
        characterCount: Int,
        encodingMode: EncodingMode,
        version: QRVersion
    ) -> ErrorCorrectionLevel? {
        for level in ErrorCorrectionLevel.descendingOrder {
            if canFit(
                characterCount: characterCount,
                encodingMode: encodingMode,
                errorCorrectionLevel: level,
                version: version
            ) {
                return level
            }
        }
        
        return nil
    }
}
