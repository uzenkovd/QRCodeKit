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
}
