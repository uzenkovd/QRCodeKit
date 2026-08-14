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
        message: String,
        encodingMode: EncodingMode
    ) -> Bool {
        let maxCapacity = CharacterCapacities.maxCapacity(for: encodingMode)
        
        return message.count <= maxCapacity
    }
    
    func canFit(
        message: String,
        encodingMode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel,
        version: QRVersion
    ) -> Bool {
        let capacity = CharacterCapacities.capacity(
            version: version,
            errorCorrectionLevel: errorCorrectionLevel,
            encodingMode: encodingMode
        )
        
        return message.count <= capacity
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
        message: String,
        encodingMode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> QRVersion? {
        let characterCount = message.count
        
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
}
