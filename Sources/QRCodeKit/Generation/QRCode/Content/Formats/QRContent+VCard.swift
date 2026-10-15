//
//  QRContent+VCard.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 13.10.2026.
//

import Foundation

public struct VCardContact: Sendable, Hashable {
    public let formattedName: String
    public let givenName: String
    public let familyName: String

    public let phoneNumbers: [String]
    public let emailAddresses: [String]

    public let organization: String?
    public let title: String?
    public let website: URL?

    public init(
        formattedName: String,
        givenName: String = "",
        familyName: String = "",
        phoneNumbers: [String] = [],
        emailAddresses: [String] = [],
        organization: String? = nil,
        title: String? = nil,
        website: URL? = nil
    ) {
        self.formattedName = formattedName
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = phoneNumbers
        self.emailAddresses = emailAddresses
        self.organization = organization
        self.title = title
        self.website = website
    }
}

public extension QRContent {
    static func vCard(
        _ contact: VCardContact
    ) throws -> QRContent {
        try validateVCardContact(contact)

        var lines = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:\(escapeVCardText(contact.familyName));\(escapeVCardText(contact.givenName));;;",
            "FN:\(escapeVCardText(contact.formattedName))"
        ]

        if let organization = contact.organization {
            lines.append("ORG:\(escapeVCardText(organization))")
        }

        if let title = contact.title {
            lines.append("TITLE:\(escapeVCardText(title))")
        }

        for number in contact.phoneNumbers {
            lines.append("TEL:\(escapeVCardText(number))")
        }

        for address in contact.emailAddresses {
            lines.append("EMAIL:\(escapeVCardText(address))")
        }

        if let website = contact.website {
            lines.append("URL:\(website.absoluteString)")
        }

        lines.append("END:VCARD")

        let payload = lines
            .map { foldVCardLine($0) }
            .joined(separator: "\r\n") + "\r\n"

        return QRContent(payload: payload)
    }
}

// MARK: - Private Helpers

private extension QRContent {
    static func validateVCardContact(
        _ contact: VCardContact
    ) throws {
        guard isValidNonEmptyVCardText(contact.formattedName) else {
            throw QRContentError.invalidVCardName
        }

        guard
            isValidVCardText(contact.givenName),
            isValidVCardText(contact.familyName),
            contact.phoneNumbers.allSatisfy(isValidSingleLineVCardField),
            contact.emailAddresses.allSatisfy(isValidSingleLineVCardField),
            contact.organization.map(isValidNonEmptyVCardText) ?? true,
            contact.title.map(isValidNonEmptyVCardText) ?? true,
            contact.website.map(isValidVCardWebsite) ?? true
        else {
            throw QRContentError.invalidVCardField
        }
    }

    static func isValidNonEmptyVCardText(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && isValidVCardText(value)
    }

    static func isValidVCardText(_ value: String) -> Bool {
        let disallowedCharacters = CharacterSet.controlCharacters
            .union(.newlines)

        return value.unicodeScalars.allSatisfy { scalar in
            scalar == "\r"
                || scalar == "\n"
                || !disallowedCharacters.contains(scalar)
        }
    }

    static func isValidSingleLineVCardField(_ value: String) -> Bool {
        let disallowedCharacters = CharacterSet.controlCharacters
            .union(.newlines)

        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && value.unicodeScalars.allSatisfy {
                !disallowedCharacters.contains($0)
            }
    }

    static func isValidVCardWebsite(_ website: URL) -> Bool {
        website.scheme != nil
            && isValidSingleLineVCardField(website.absoluteString)
    }

    static func escapeVCardText(_ value: String) -> String {
        let normalized = value
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        var escaped = String()
        escaped.reserveCapacity(normalized.utf8.count)

        for scalar in normalized.unicodeScalars {
            switch scalar {
            case "\\", ";", ",":
                escaped.append("\\")
                escaped.unicodeScalars.append(scalar)

            case "\n":
                escaped.append("\\n")

            default:
                escaped.unicodeScalars.append(scalar)
            }
        }

        return escaped
    }

    static func foldVCardLine(_ line: String) -> String {
        var folded = String()
        folded.reserveCapacity(line.utf8.count)

        var lineByteCount = 0

        for scalar in line.unicodeScalars {
            let byteCount = String(scalar).utf8.count

            if lineByteCount + byteCount > 75 {
                folded.append("\r\n ")
                lineByteCount = 1
            }

            folded.unicodeScalars.append(scalar)
            lineByteCount += byteCount
        }

        return folded
    }
}
