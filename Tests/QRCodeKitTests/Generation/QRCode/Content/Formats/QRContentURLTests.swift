//
//  QRContentURLTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Foundation
import Testing

@testable import QRCodeKit

@Suite
struct QRContentURLTests {
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
            content.payload
                == "https://example.com/search?q=swift&page=2#results"
        )
    }

    @Test
    func preservesPercentEncodedURL() {
        let url = URL(
            string: "https://example.com/search?q=hello%20world"
        )!

        let content = QRContent.url(url)

        #expect(
            content.payload
                == "https://example.com/search?q=hello%20world"
        )
    }
}
