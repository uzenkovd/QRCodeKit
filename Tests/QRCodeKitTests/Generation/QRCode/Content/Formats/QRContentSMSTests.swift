//
//  QRContentSMSTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRContentSMSTests {
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
        #expect(throws: QRContentError.invalidPhoneNumber) {
            try QRContent.sms("Hello", body: "Test")
        }
    }
}
