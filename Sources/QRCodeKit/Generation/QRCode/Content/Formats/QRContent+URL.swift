//
//  QRContent+URL.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Foundation

public extension QRContent {
    static func url(
        _ url: URL
    ) -> QRContent {
        QRContent(payload: url.absoluteString)
    }
}
