//
//  QRContentPercentEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Foundation

enum QRContentPercentEncoder {
    static func encode(_ value: String) -> String {
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
