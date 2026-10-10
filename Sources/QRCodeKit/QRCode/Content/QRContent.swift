//
//  QRContent.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.10.2026.
//

import Foundation

public struct QRContent: Sendable, Hashable {
    public let payload: String

    init(payload: String) {
        self.payload = payload
    }
}

// MARK: - Content Factories

public extension QRContent {
    // MARK: Plain Text

    static func text(
        _ text: String
    ) -> QRContent {
        QRContent(payload: text)
    }

    // MARK: URL

    static func url(
        _ url: URL
    ) -> QRContent {
        QRContent(payload: url.absoluteString)
    }

    // MARK: Phone

    static func phone(
        _ number: String
    ) throws -> QRContent {
        guard isValidPhoneNumber(number) else {
            throw QRContentError.invalidPhoneNumber
        }

        return QRContent(payload: "tel:\(number)")
    }

    // MARK: SMS

    static func sms(
        _ number: String,
        body: String? = nil
    ) throws -> QRContent {
        guard isValidPhoneNumber(number) else {
            throw QRContentError.invalidPhoneNumber
        }

        var payload = "sms:\(number)"

        if let body {
            payload += "?body=\(percentEncode(body))"
        }

        return QRContent(payload: payload)
    }
}

// MARK: - Private Helpers

private extension QRContent {
    static func isValidPhoneNumber(_ number: String) -> Bool {
        let bytes = number.utf8
        let digits = bytes.dropFirst()

        let zero = UInt8(ascii: "0")
        let nine = UInt8(ascii: "9")

        return bytes.first == UInt8(ascii: "+")
            && (3...15).contains(digits.count)
            && digits.first != zero
            && digits.allSatisfy { $0 >= zero && $0 <= nine }
    }

    static func percentEncode(_ value: String) -> String {
        let allowedCharacters = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        )

        guard let encoded = value.addingPercentEncoding(
            withAllowedCharacters: allowedCharacters
        ) else {
            preconditionFailure("Failed to percent-encode QR content")
        }

        return encoded
    }
}
