//
//  QRContent+SMS.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

public extension QRContent {
    static func sms(
        _ number: String,
        body: String? = nil
    ) throws -> QRContent {
        guard PhoneNumberValidator.isValidInternational(number) else {
            throw QRContentError.invalidPhoneNumber
        }

        var payload = "sms:\(number)"

        if let body {
            payload += "?body=\(PercentEncoder.encode(body))"
        }

        return QRContent(payload: payload)
    }
}
