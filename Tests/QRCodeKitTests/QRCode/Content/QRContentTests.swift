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

    // MARK: - email(_:subject:body:)

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

        #expect(throws: QRContentError.self) {
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

        #expect(throws: QRContentError.self) {
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
        "hello@-example.com",
        "hello@example..com",
        "hello@ex_ample.com",
        "привіт@example.com"
    ])
    func rejectsInvalidEmailAddresses(_ address: String) {
        #expect(throws: QRContentError.self) {
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
        #expect(throws: QRContentError.self) {
            try QRContent.email(
                "hello@example.com",
                subject: subject
            )
        }
    }

    // MARK: - geo(latitude:longitude:altitude:uncertainty:)

    @Test
    func createsGeolocationContent() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234
        )

        #expect(content.payload == "geo:50.4501,30.5234")
    }

    @Test
    func createsGeolocationContentWithAltitude() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: 180
        )

        #expect(content.payload == "geo:50.4501,30.5234,180")
    }

    @Test
    func createsGeolocationContentWithUncertainty() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            uncertainty: 10
        )

        #expect(content.payload == "geo:50.4501,30.5234;u=10")
    }

    @Test
    func createsGeolocationContentWithAllParameters() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: 180,
            uncertainty: 10
        )

        #expect(content.payload == "geo:50.4501,30.5234,180;u=10")
    }

    @Test
    func preservesZeroAltitude() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: 0
        )

        #expect(content.payload == "geo:50.4501,30.5234,0")
    }

    @Test
    func preservesZeroUncertainty() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            uncertainty: 0
        )

        #expect(content.payload == "geo:50.4501,30.5234;u=0")
    }

    @Test
    func acceptsNegativeAltitude() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: -25.5
        )

        #expect(content.payload == "geo:50.4501,30.5234,-25.5")
    }

    @Test(arguments: [
        -90.0,
        90.0
    ])
    func acceptsLatitudeBoundaryValues(_ latitude: Double) throws {
        let content = try QRContent.geo(
            latitude: latitude,
            longitude: 30
        )

        #expect(content.payload == "geo:\(Int(latitude)),30")
    }

    @Test(arguments: [
        -180.0,
        180.0
    ])
    func acceptsLongitudeBoundaryValues(_ longitude: Double) throws {
        let content = try QRContent.geo(
            latitude: 50,
            longitude: longitude
        )

        #expect(content.payload == "geo:50,\(Int(longitude))")
    }

    @Test
    func formatsSmallGeolocationCoordinates() throws {
        let content = try QRContent.geo(
            latitude: 0.0000001,
            longitude: -0.0000001
        )

        #expect(content.payload == "geo:0.0000001,-0.0000001")
    }

    @Test
    func preservesGeolocationCoordinatePrecision() throws {
        let content = try QRContent.geo(
            latitude: 1.0000000000000002,
            longitude: 30
        )

        #expect(content.payload == "geo:1.0000000000000002,30")
    }

    @Test
    func normalizesNegativeZero() throws {
        let content = try QRContent.geo(
            latitude: -0.0,
            longitude: -0.0,
            altitude: -0.0,
            uncertainty: -0.0
        )

        #expect(content.payload == "geo:0,0,0;u=0")
    }

    @Test(arguments: [
        -90.0001,
        90.0001,
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidLatitudes(_ latitude: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: latitude,
                longitude: 30
            )
        }
    }

    @Test(arguments: [
        -180.0001,
        180.0001,
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidLongitudes(_ longitude: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: 50,
                longitude: longitude
            )
        }
    }

    @Test(arguments: [
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidAltitudes(_ altitude: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: 50,
                longitude: 30,
                altitude: altitude
            )
        }
    }

    @Test(arguments: [
        -0.1,
        -1.0,
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidUncertainty(_ uncertainty: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: 50,
                longitude: 30,
                uncertainty: uncertainty
            )
        }
    }

    @Test
    func preservesSmallestGeolocationCoordinate() throws {
        let value = Double.leastNonzeroMagnitude

        let content = try QRContent.geo(
            latitude: value,
            longitude: 0
        )

        let coordinate = content.payload
            .dropFirst("geo:".count)
            .split(separator: ",")[0]

        #expect(!coordinate.lowercased().contains("e"))
        #expect(Double(coordinate) == value)
    }
}
