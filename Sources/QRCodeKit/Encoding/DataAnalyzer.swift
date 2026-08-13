//
//  DataAnalyzer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.08.2026.
//

struct DataAnalyzer {
    func canEncode(_ message: String) -> Bool {
        for mode in EncodingMode.allCases {
            if mode.canEncode(message) {
                return true
            }
        }
        
        return false
    }
    
    func canFit(message: String, encodingMode: EncodingMode) -> Bool {
        let maxCapacity = CharacterCapacities.maxCapacity(for: encodingMode)
        
        return message.count <= maxCapacity
    }
    
    func recommendedVersion(message: String, encodingMode: EncodingMode, errorCorrectionLevel: ErrorCorrectionLevel) -> QRVersion? {
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
