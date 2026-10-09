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

    // MARK: - phone(_:)

    @Test
    func createsPhoneContent() throws {
        let content = try QRContent.phone("+380501234567")

        #expect(content.payload == "tel:+380501234567")
    }

    @Test(arguments: [
        "+123",
        "+123456789012345"
    ])
    func acceptsPhoneNumberBoundaryLengths(_ number: String) throws {
        let content = try QRContent.phone(number)

        #expect(content.payload == "tel:\(number)")
    }

    @Test(arguments: [
        "",
        "+",
        "+12",
        "380501234567",
        "Hello",
        "+0123456789",
        "+380 50 123 45 67",
        "+1-201-555-0123",
        "+1234567890123456",
        "++380501234567",
        "+38050abc4567",
        "+٣٨٠٥٠١٢٣٤٥٦٧"
    ])
    func rejectsInvalidPhoneNumbers(_ number: String) {
        #expect(throws: QRContentError.self) {
            try QRContent.phone(number)
        }
    }
}
