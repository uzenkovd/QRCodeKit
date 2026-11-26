//
//  QRContent.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.10.2026.
//

public struct QRContent: Hashable, Sendable {
    public let payload: String

    public static func text(
        _ text: String
    ) -> QRContent {
        QRContent(payload: text)
    }
}
