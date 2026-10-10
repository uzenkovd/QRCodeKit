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
        "+٣٨٠",
        "+3\u{0301}12"
    ])
    func rejectsInvalidPhoneNumbers(_ number: String) {
        #expect(throws: QRContentError.self) {
            try QRContent.phone(number)
        }
    }

    // MARK: - sms(_:body:)

    @Test
    func createsSMSContent() throws {
        let content = try QRContent.sms("+380501234567")

        #expect(content.payload == "sms:+380501234567")
    }

    @Test
    func createsSMSContentWithBody() throws {
        let content = try QRContent.sms(
            "+380501234567",
            body: "Hello"
        )

        #expect(content.payload == "sms:+380501234567?body=Hello")
    }

    @Test
    func preservesEmptySMSBody() throws {
        let content = try QRContent.sms(
            "+380501234567",
            body: ""
        )

        #expect(content.payload == "sms:+380501234567?body=")
    }

    @Test
    func percentEncodesSMSBody() throws {
        let content = try QRContent.sms(
            "+380501234567",
            body: "Hello & welcome!"
        )

        #expect(
            content.payload
                == "sms:+380501234567?body=Hello%20%26%20welcome%21"
        )
    }

    @Test
    func percentEncodesUnicodeSMSBody() throws {
        let content = try QRContent.sms(
            "+380501234567",
            body: "Привіт!"
        )

        #expect(
            content.payload
                == "sms:+380501234567?body=%D0%9F%D1%80%D0%B8%D0%B2%D1%96%D1%82%21"
        )
    }

    @Test
    func percentEncodesSMSBodyWithLineBreak() throws {
        let content = try QRContent.sms(
            "+380501234567",
            body: "Hello\nWorld"
        )

        #expect(
            content.payload
                == "sms:+380501234567?body=Hello%0AWorld"
        )
    }

    @Test
    func percentEncodesSMSReservedCharacters() throws {
        let content = try QRContent.sms(
            "+380501234567",
            body: "50% off?"
        )

        #expect(
            content.payload
                == "sms:+380501234567?body=50%25%20off%3F"
        )
    }

    @Test
    func rejectsInvalidSMSPhoneNumber() {
        #expect(throws: QRContentError.self) {
            try QRContent.sms("Hello", body: "Test")
        }
    }
}
