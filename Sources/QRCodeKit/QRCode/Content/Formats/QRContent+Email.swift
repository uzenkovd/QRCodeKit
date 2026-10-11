//
//  QRContent+Email.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Foundation

public extension QRContent {
    static func email(
        _ address: String,
        subject: String? = nil,
        body: String? = nil
    ) throws -> QRContent {
        guard QREmailAddressValidator.isValid(address) else {
            throw QRContentError.invalidEmailAddress
        }

        let parts = address.split(
            separator: "@",
            omittingEmptySubsequences: false
        )

        let localPart = QRContentPercentEncoder.encode(
            String(parts[0])
        )
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

            queryItems.append(
                "subject=\(QRContentPercentEncoder.encode(subject))"
            )
        }

        if let body {
            let normalizedBody = body
                .replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\r", with: "\n")
                .replacingOccurrences(of: "\n", with: "\r\n")

            queryItems.append(
                "body=\(QRContentPercentEncoder.encode(normalizedBody))"
            )
        }

        if !queryItems.isEmpty {
            payload += "?" + queryItems.joined(separator: "&")
        }

        return QRContent(payload: payload)
    }
}
