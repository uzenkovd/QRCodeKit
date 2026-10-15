//
//  QRContentWiFiTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRContentWiFiTests {
    @Test
    func createsOpenWiFiContent() throws {
        let content = try QRContent.wifi(
            ssid: "GuestNetwork",
            security: .open
        )

        #expect(
            content.payload == "WIFI:T:nopass;S:GuestNetwork;;"
        )
    }

    @Test
    func createsWPAWiFiContent() throws {
        let content = try QRContent.wifi(
            ssid: "HomeNetwork",
            security: .wpa(password: "secret123")
        )

        #expect(
            content.payload
                == "WIFI:T:WPA;S:HomeNetwork;P:secret123;;"
        )
    }

    @Test
    func createsWPA3WiFiContent() throws {
        let content = try QRContent.wifi(
            ssid: "HomeNetwork",
            security: .wpa3(password: "secret123")
        )

        #expect(
            content.payload
                == "WIFI:T:WPA;R:1;S:HomeNetwork;P:secret123;;"
        )
    }

    @Test(arguments: [
        "ABCDE",
        "ABCDEFGHIJKLM",
        "0123456789",
        String(repeating: "AB", count: 13)
    ])
    func createsWEPWiFiContent(_ key: String) throws {
        let content = try QRContent.wifi(
            ssid: "LegacyNetwork",
            security: .wep(key: key)
        )

        #expect(
            content.payload
                == "WIFI:T:WEP;S:LegacyNetwork;P:\(key);;"
        )
    }

    @Test
    func createsHiddenWiFiContent() throws {
        let content = try QRContent.wifi(
            ssid: "HiddenNetwork",
            security: .wpa(password: "secret123"),
            hidden: true
        )

        #expect(
            content.payload
                == "WIFI:T:WPA;S:HiddenNetwork;H:true;P:secret123;;"
        )
    }

    @Test
    func escapesWiFiSSIDSpecialCharacters() throws {
        let content = try QRContent.wifi(
            ssid: "Lab\\;,:\"",
            security: .open
        )

        #expect(
            content.payload
                == #"WIFI:T:nopass;S:Lab\\\;\,\:\";;"#
        )
    }

    @Test
    func escapesWiFiPasswordSpecialCharacters() throws {
        let content = try QRContent.wifi(
            ssid: "Home",
            security: .wpa(password: "abc\\;,:\"123")
        )

        #expect(
            content.payload
                == #"WIFI:T:WPA;S:Home;P:abc\\\;\,\:\"123;;"#
        )
    }

    @Test
    func preservesUnicodeWiFiFields() throws {
        let content = try QRContent.wifi(
            ssid: "Мережа",
            security: .wpa3(password: "пароль🔐")
        )

        #expect(
            content.payload
                == "WIFI:T:WPA;R:1;S:Мережа;P:пароль🔐;;"
        )
    }

    @Test
    func preservesWiFiSSIDWhitespace() throws {
        let content = try QRContent.wifi(
            ssid: " Home ",
            security: .open
        )

        #expect(
            content.payload == "WIFI:T:nopass;S: Home ;;"
        )
    }

    @Test(arguments: [
        "A",
        String(repeating: "A", count: 32),
        String(repeating: "і", count: 16)
    ])
    func acceptsWiFiSSIDBoundaryLengths(_ ssid: String) throws {
        let content = try QRContent.wifi(
            ssid: ssid,
            security: .open
        )

        #expect(
            content.payload == "WIFI:T:nopass;S:\(ssid);;"
        )
    }

    @Test(arguments: [
        "",
        String(repeating: "A", count: 33),
        String(repeating: "і", count: 17),
        "Home\nNetwork",
        "Home\u{0000}Network"
    ])
    func rejectsInvalidWiFiSSIDs(_ ssid: String) {
        #expect(throws: QRContentError.invalidWiFiSSID) {
            try QRContent.wifi(
                ssid: ssid,
                security: .open
            )
        }
    }

    @Test(arguments: [
        "",
        "ABCD",
        "ABCDEF",
        "123456789G",
        "ABCé",
        String(repeating: "A", count: 16)
    ])
    func rejectsInvalidWEPKeys(_ key: String) {
        #expect(throws: QRContentError.invalidWiFiCredential) {
            try QRContent.wifi(
                ssid: "Legacy",
                security: .wep(key: key)
            )
        }
    }

    @Test(arguments: [
        String(repeating: "a", count: 8),
        String(repeating: "a", count: 63)
    ])
    func acceptsWPAPasswordBoundaryLengths(
        _ password: String
    ) throws {
        let content = try QRContent.wifi(
            ssid: "Home",
            security: .wpa(password: password)
        )

        #expect(
            content.payload
                == "WIFI:T:WPA;S:Home;P:\(password);;"
        )
    }

    @Test
    func acceptsWPAHexadecimalKey() throws {
        let key = String(repeating: "aB", count: 32)

        let content = try QRContent.wifi(
            ssid: "Home",
            security: .wpa(password: key)
        )

        #expect(
            content.payload == "WIFI:T:WPA;S:Home;P:\(key);;"
        )
    }

    @Test(arguments: [
        "",
        "1234567",
        String(repeating: "g", count: 64),
        String(repeating: "a", count: 65),
        "пароль123",
        "secret\n123"
    ])
    func rejectsInvalidWPACredentials(_ password: String) {
        #expect(throws: QRContentError.invalidWiFiCredential) {
            try QRContent.wifi(
                ssid: "Home",
                security: .wpa(password: password)
            )
        }
    }

    @Test(arguments: [
        "a",
        "Привіт🔐",
        String(repeating: "g", count: 64)
    ])
    func acceptsSAEPasswordVariations(
        _ password: String
    ) throws {
        let content = try QRContent.wifi(
            ssid: "SecureNetwork",
            security: .wpa3(password: password)
        )

        #expect(
            content.payload
                == "WIFI:T:WPA;R:1;S:SecureNetwork;P:\(password);;"
        )
    }

    @Test(arguments: [
        "",
        "secret\n123",
        "secret\u{0000}123"
    ])
    func rejectsInvalidSAEPasswords(_ password: String) {
        #expect(throws: QRContentError.invalidWiFiCredential) {
            try QRContent.wifi(
                ssid: "SecureNetwork",
                security: .wpa3(password: password)
            )
        }
    }
}
