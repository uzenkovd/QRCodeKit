//
//  EncodingMode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum EncodingMode: CaseIterable {
    case numeric
    case alphanumeric
    case byte
    case kanji
    
    func canEncode(_ message: String) -> Bool {
        switch self {
        case .numeric:
            return message.allSatisfy { $0 >= "0" && $0 <= "9" }
        case .alphanumeric:
            return message.allSatisfy {
                AlphanumericTable.values[$0] != nil
            }
        case .byte:
            return false
        case .kanji:
            return false
        }
    }
}
