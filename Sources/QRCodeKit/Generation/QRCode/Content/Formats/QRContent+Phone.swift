//
//  QRContent+Phone.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

public extension QRContent {
    static func phone(
        _ number: String
    ) throws -> QRContent {
        guard QRPhoneNumberValidator.isValidInternational(number) else {
            throw QRContentError.invalidPhoneNumber
        }

        return QRContent(payload: "tel:\(number)")
    }
}
