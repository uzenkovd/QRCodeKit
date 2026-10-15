//
//  QRContentPhoneTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRContentPhoneTests {
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
        #expect(throws: QRContentError.invalidPhoneNumber) {
            try QRContent.phone(number)
        }
    }
}
