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

    // MARK: Email

    static func email(
        _ address: String,
        subject: String? = nil,
        body: String? = nil
    ) throws -> QRContent {
        let parts = address.split(
            separator: "@",
            omittingEmptySubsequences: false
        )

        guard
            parts.count == 2,
            address.utf8.count <= 254,
            isValidEmailLocalPart(parts[0]),
            isValidEmailDomain(parts[1])
        else {
            throw QRContentError.invalidEmailAddress
        }

        let localPart = percentEncode(String(parts[0]))
        let domain = parts[1]

        var payload = "mailto:\(localPart)@\(domain)"
        var queryItems: [String] = []

        if let subject {
            guard subject.unicodeScalars.allSatisfy({
                !CharacterSet.controlCharacters.contains($0)
                    && !CharacterSet.newlines.contains($0)
            }) else {
                throw QRContentError.invalidEmailSubject
            }

            queryItems.append("subject=\(percentEncode(subject))")
        }

        if let body {
            let normalizedBody = body
                .replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\r", with: "\n")
                .replacingOccurrences(of: "\n", with: "\r\n")

            queryItems.append("body=\(percentEncode(normalizedBody))")
        }

        if !queryItems.isEmpty {
            payload += "?" + queryItems.joined(separator: "&")
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

    static func isValidEmailLocalPart(_ localPart: Substring) -> Bool {
        guard (1...64).contains(localPart.utf8.count) else {
            return false
        }

        let allowedCharacters = Set(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~".utf8
        )

        let atoms = localPart.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        return atoms.allSatisfy { atom in
            !atom.isEmpty
                && atom.utf8.allSatisfy { allowedCharacters.contains($0) }
        }
    }

    static func isValidEmailDomain(_ domain: Substring) -> Bool {
        guard (1...253).contains(domain.utf8.count) else {
            return false
        }

        let allowedCharacters = Set(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-".utf8
        )

        let labels = domain.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        return labels.allSatisfy { label in
            let bytes = label.utf8

            return (1...63).contains(bytes.count)
                && bytes.first != UInt8(ascii: "-")
                && bytes.last != UInt8(ascii: "-")
                && bytes.allSatisfy { allowedCharacters.contains($0) }
        }
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
