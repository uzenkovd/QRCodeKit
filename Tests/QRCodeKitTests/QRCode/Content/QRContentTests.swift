//
//  QRContentTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.10.2026.
//

import Foundation
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

    // MARK: - url(_:)

    @Test
    func createsURLContent() {
        let url = URL(string: "https://example.com")!

        let content = QRContent.url(url)

        #expect(content.payload == "https://example.com")
    }

    @Test
    func preservesURLComponents() {
        let url = URL(
            string: "https://example.com/search?q=swift&page=2#results"
        )!

        let content = QRContent.url(url)

        #expect(
            content.payload ==
            "https://example.com/search?q=swift&page=2#results"
        )
    }

    @Test
    func preservesPercentEncodedURL() {
        let url = URL(
            string: "https://example.com/search?q=hello%20world"
        )!

        let content = QRContent.url(url)

        #expect(
            content.payload ==
            "https://example.com/search?q=hello%20world"
        )
    }
}
