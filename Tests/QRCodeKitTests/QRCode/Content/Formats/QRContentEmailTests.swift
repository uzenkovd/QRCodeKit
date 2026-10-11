//
//  QRContentEmailTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRContentEmailTests {
    @Test
    func createsEmailContent() throws {
        let content = try QRContent.email("hello@example.com")

        #expect(content.payload == "mailto:hello@example.com")
    }

    @Test
    func createsEmailContentWithSubject() throws {
        let content = try QRContent.email(
            "hello@example.com",
            subject: "Question"
        )

        #expect(
            content.payload == "mailto:hello@example.com?subject=Question"
        )
    }

    @Test
    func createsEmailContentWithBody() throws {
        let content = try QRContent.email(
            "hello@example.com",
            body: "Hello!"
        )

        #expect(
            content.payload == "mailto:hello@example.com?body=Hello%21"
        )
    }

    @Test
    func createsEmailContentWithSubjectAndBody() throws {
        let content = try QRContent.email(
            "hello@example.com",
            subject: "Question",
            body: "Hello World!"
        )

        #expect(
            content.payload
                == "mailto:hello@example.com?subject=Question&body=Hello%20World%21"
        )
    }

    @Test
    func preservesEmptyEmailFields() throws {
        let content = try QRContent.email(
            "hello@example.com",
            subject: "",
            body: ""
        )

        #expect(
            content.payload == "mailto:hello@example.com?subject=&body="
        )
    }

    @Test
    func acceptsEmailAddressWithDotsAndSubdomain() throws {
        let content = try QRContent.email(
            "first.last@sub.example.com"
        )

        #expect(
            content.payload == "mailto:first.last@sub.example.com"
        )
    }

    @Test
    func percentEncodesEmailLocalPart() throws {
        let content = try QRContent.email(
            "hello+work@example.com"
        )

        #expect(
            content.payload == "mailto:hello%2Bwork@example.com"
        )
    }

    @Test
    func percentEncodesEmailLocalPartSpecialCharacters() throws {
        let content = try QRContent.email(
            "Mike&family@example.org"
        )

        #expect(
            content.payload == "mailto:Mike%26family@example.org"
        )
    }

    @Test
    func percentEncodesEmailSubject() throws {
        let content = try QRContent.email(
            "hello@example.com",
            subject: "Hello & welcome!"
        )

        #expect(
            content.payload
                == "mailto:hello@example.com?subject=Hello%20%26%20welcome%21"
        )
    }

    @Test
    func percentEncodesUnicodeEmailBody() throws {
        let content = try QRContent.email(
            "hello@example.com",
            body: "Привіт!"
        )

        #expect(
            content.payload
                == "mailto:hello@example.com?body=%D0%9F%D1%80%D0%B8%D0%B2%D1%96%D1%82%21"
        )
    }

    @Test
    func normalizesEmailBodyLineBreaks() throws {
        let content = try QRContent.email(
            "hello@example.com",
            body: "First\nSecond\rThird\r\nFourth"
        )

        #expect(
            content.payload
                == "mailto:hello@example.com?body=First%0D%0ASecond%0D%0AThird%0D%0AFourth"
        )
    }

    @Test
    func validatesEmailLocalPartLength() throws {
        let validAddress = String(repeating: "a", count: 64)
            + "@example.com"

        let invalidAddress = String(repeating: "a", count: 65)
            + "@example.com"

        let content = try QRContent.email(validAddress)

        #expect(content.payload == "mailto:\(validAddress)")

        #expect(throws: QRContentError.invalidEmailAddress) {
            try QRContent.email(invalidAddress)
        }
    }

    @Test
    func validatesEmailDomainLabelLength() throws {
        let validLabel = String(repeating: "a", count: 63)
        let invalidLabel = String(repeating: "a", count: 64)

        let validAddress = "hello@\(validLabel).com"
        let invalidAddress = "hello@\(invalidLabel).com"

        let content = try QRContent.email(validAddress)

        #expect(content.payload == "mailto:\(validAddress)")

        #expect(throws: QRContentError.invalidEmailAddress) {
            try QRContent.email(invalidAddress)
        }
    }

    @Test(arguments: [
        "",
        "hello",
        "@example.com",
        "hello@",
        "hello@@example.com",
        ".hello@example.com",
        "hello.@example.com",
        "hello..world@example.com",
        "hello world@example.com",
        "hello@.example.com",
        "hello@example.com.",
        "hello@example-.com",
        "hello@-example.com",
        "hello@example..com",
        "hello@ex_ample.com",
        "привіт@example.com"
    ])
    func rejectsInvalidEmailAddresses(_ address: String) {
        #expect(throws: QRContentError.invalidEmailAddress) {
            try QRContent.email(address)
        }
    }

    @Test(arguments: [
        "Hello\nBcc:other@example.com",
        "Hello\rWorld",
        "Hello\u{2028}World",
        "Hello\u{0000}World"
    ])
    func rejectsInvalidEmailSubject(_ subject: String) {
        #expect(throws: QRContentError.invalidEmailSubject) {
            try QRContent.email(
                "hello@example.com",
                subject: subject
            )
        }
    }

    @Test
    func validatesEmailAddressTotalLength() throws {
        let localPart = String(repeating: "a", count: 64)

        let domain = String(repeating: "b", count: 63)
            + "."
            + String(repeating: "c", count: 63)
            + "."
            + String(repeating: "d", count: 61)

        let validAddress = "\(localPart)@\(domain)"
        let invalidAddress = validAddress + "d"

        #expect(validAddress.utf8.count == 254)
        #expect(invalidAddress.utf8.count == 255)

        let content = try QRContent.email(validAddress)

        #expect(content.payload == "mailto:\(validAddress)")

        #expect(throws: QRContentError.invalidEmailAddress) {
            try QRContent.email(invalidAddress)
        }
    }
}
