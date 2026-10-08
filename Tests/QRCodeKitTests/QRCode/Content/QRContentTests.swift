//
//  QRContentTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRContentTests {
    // MARK: - text(_:)

    @Test
    func createsPlainTextContent() {
        let content = QRContent.text("HELLO WORLD")

        #expect(content.payload == "HELLO WORLD")
    }
}
