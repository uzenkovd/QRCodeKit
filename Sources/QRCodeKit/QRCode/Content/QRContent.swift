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
