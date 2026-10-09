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

// MARK: - Plain Text

public extension QRContent {
    static func text(
        _ text: String
    ) -> QRContent {
        QRContent(payload: text)
    }
}

// MARK: - URL

public extension QRContent {
    static func url(
        _ url: URL
    ) -> QRContent {
        QRContent(payload: url.absoluteString)
    }
}

// MARK: - Phone

public extension QRContent {
    static func phone(
        _ number: String
    ) throws -> QRContent {
        guard isValidPhoneNumber(number) else {
            throw QRContentError.invalidPhoneNumber
        }

        return QRContent(payload: "tel:\(number)")
    }
}

// MARK: - Validation

private extension QRContent {
    static func isValidPhoneNumber(_ number: String) -> Bool {
        let digits = number.dropFirst()

        return number.first == "+"
            && (3...15).contains(digits.count)
            && digits.first != "0"
            && digits.allSatisfy { $0 >= "0" && $0 <= "9" }
    }
}
