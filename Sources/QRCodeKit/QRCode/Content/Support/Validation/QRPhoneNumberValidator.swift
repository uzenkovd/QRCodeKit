//
//  QRPhoneNumberValidator.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

enum QRPhoneNumberValidator {
    static func isValidInternational(_ number: String) -> Bool {
        let bytes = number.utf8
        let digits = bytes.dropFirst()

        let zero = UInt8(ascii: "0")
        let nine = UInt8(ascii: "9")

        return bytes.first == UInt8(ascii: "+")
            && (3...15).contains(digits.count)
            && digits.first != zero
            && digits.allSatisfy { $0 >= zero && $0 <= nine }
    }
}
