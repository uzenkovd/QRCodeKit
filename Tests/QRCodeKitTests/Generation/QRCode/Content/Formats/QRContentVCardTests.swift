//
//  QRContentVCardTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 13.10.2026.
//

import Foundation
import Testing

@testable import QRCodeKit

@Suite
struct QRContentVCardTests {
    @Test
    func createsMinimalVCardContent() throws {
        let contact = VCardContact(
            formattedName: "John"
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;;;;",
            "FN:John",
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func createsVCardWithStructuredName() throws {
        let contact = VCardContact(
            formattedName: "Ivan Ivanenko",
            givenName: "Ivan",
            familyName: "Ivanenko"
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:Ivanenko;Ivan;;;",
            "FN:Ivan Ivanenko",
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func createsVCardWithAllSupportedFields() throws {
        let website = try #require(
            URL(string: "https://example.com/contact?x=1,y=2")
        )

        let contact = VCardContact(
            formattedName: "Ivan Ivanenko",
            givenName: "Ivan",
            familyName: "Ivanenko",
            phoneNumbers: [
                "+380501234567",
                "050 123 45 67"
            ],
            emailAddresses: [
                "ivan@example.com",
                "ivan.work@example.com"
            ],
            organization: "Example Company",
            title: "iOS Developer",
            website: website
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:Ivanenko;Ivan;;;",
            "FN:Ivan Ivanenko",
            "ORG:Example Company",
            "TITLE:iOS Developer",
            "TEL:+380501234567",
            "TEL:050 123 45 67",
            "EMAIL:ivan@example.com",
            "EMAIL:ivan.work@example.com",
            "URL:https://example.com/contact?x=1,y=2",
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func preservesUnicodeVCardFields() throws {
        let contact = VCardContact(
            formattedName: "Іван Іваненко",
            givenName: "Іван",
            familyName: "Іваненко",
            organization: "Українська компанія"
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:Іваненко;Іван;;;",
            "FN:Іван Іваненко",
            "ORG:Українська компанія",
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func escapesVCardTextSpecialCharacters() throws {
        let contact = VCardContact(
            formattedName: "Alex, Lee; Team\\Lead",
            givenName: "Alex, Jr.",
            familyName: "Lee;Smith",
            organization: "Example, Inc.; R&D",
            title: "Lead\\Engineer\nPlatform"
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            #"N:Lee\;Smith;Alex\, Jr.;;;"#,
            #"FN:Alex\, Lee\; Team\\Lead"#,
            #"ORG:Example\, Inc.\; R&D"#,
            #"TITLE:Lead\\Engineer\nPlatform"#,
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func normalizesVCardTextLineBreaks() throws {
        let contact = VCardContact(
            formattedName: "First\r\nSecond\rThird\nFourth"
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;;;;",
            #"FN:First\nSecond\nThird\nFourth"#,
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func foldsLongVCardLines() throws {
        let name = String(repeating: "a", count: 73)

        let contact = VCardContact(
            formattedName: name
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;;;;",
            "FN:" + String(repeating: "a", count: 72) + "\r\n a",
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)
    }

    @Test
    func foldsUnicodeVCardLinesWithoutSplittingUTF8() throws {
        let name = String(repeating: "і", count: 37)

        let contact = VCardContact(
            formattedName: name
        )

        let content = try QRContent.vCard(contact)

        let expected = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;;;;",
            "FN:" + String(repeating: "і", count: 36) + "\r\n і",
            "END:VCARD"
        ].joined(separator: "\r\n") + "\r\n"

        #expect(content.payload == expected)

        for line in content.payload.components(separatedBy: "\r\n") {
            #expect(line.utf8.count <= 75)
        }
    }

    @Test(arguments: [
        "",
        " ",
        "\n",
        "John\u{0000}"
    ])
    func rejectsInvalidVCardFormattedNames(_ name: String) {
        let contact = VCardContact(
            formattedName: name
        )

        #expect(throws: QRContentError.invalidVCardName) {
            try QRContent.vCard(contact)
        }
    }

    @Test(arguments: [
        "Ivan\u{0000}",
        "Ivan\u{2028}"
    ])
    func rejectsInvalidVCardNameComponents(_ name: String) {
        let contact = VCardContact(
            formattedName: "Ivan Ivanenko",
            givenName: name
        )

        #expect(throws: QRContentError.invalidVCardField) {
            try QRContent.vCard(contact)
        }
    }

    @Test(arguments: [
        VCardContact(
            formattedName: "John",
            phoneNumbers: [""]
        ),
        VCardContact(
            formattedName: "John",
            phoneNumbers: ["123\n456"]
        ),
        VCardContact(
            formattedName: "John",
            emailAddresses: [""]
        ),
        VCardContact(
            formattedName: "John",
            emailAddresses: ["john@example.com\r\nFN:Injected"]
        )
    ])
    func rejectsInvalidVCardContactDetails(
        _ contact: VCardContact
    ) {
        #expect(throws: QRContentError.invalidVCardField) {
            try QRContent.vCard(contact)
        }
    }

    @Test(arguments: [
        VCardContact(
            formattedName: "John",
            organization: ""
        ),
        VCardContact(
            formattedName: "John",
            organization: "Example\u{0000}"
        ),
        VCardContact(
            formattedName: "John",
            title: " "
        ),
        VCardContact(
            formattedName: "John",
            title: "Developer\u{2028}"
        )
    ])
    func rejectsInvalidVCardOptionalTextFields(
        _ contact: VCardContact
    ) {
        #expect(throws: QRContentError.invalidVCardField) {
            try QRContent.vCard(contact)
        }
    }

    @Test
    func rejectsRelativeVCardWebsite() throws {
        let website = try #require(
            URL(string: "/contact")
        )

        let contact = VCardContact(
            formattedName: "John",
            website: website
        )

        #expect(throws: QRContentError.invalidVCardField) {
            try QRContent.vCard(contact)
        }
    }
}
