//
//  QRContent+WiFi.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.10.2026.
//

import Foundation

public enum WiFiSecurity: Sendable, Hashable {
    case open
    case wep(key: String)
    case wpa(password: String)
    case wpa3(password: String)
}

public extension QRContent {
    static func wifi(
        ssid: String,
        security: WiFiSecurity,
        hidden: Bool = false
    ) throws -> QRContent {
        guard isValidWiFiSSID(ssid) else {
            throw QRContentError.invalidWiFiSSID
        }

        let configuration = try resolveWiFiSecurity(security)

        var payload = "WIFI:T:\(configuration.type);"

        if configuration.transitionDisable {
            payload += "R:1;"
        }

        payload += "S:\(escapeWiFiField(ssid));"

        if hidden {
            payload += "H:true;"
        }

        if let credential = configuration.credential {
            payload += "P:\(escapeWiFiField(credential));"
        }

        payload += ";"

        return QRContent(payload: payload)
    }
}

// MARK: - Private Helpers

private extension QRContent {
    static func resolveWiFiSecurity(
        _ security: WiFiSecurity
    ) throws -> (
        type: String,
        credential: String?,
        transitionDisable: Bool
    ) {
        switch security {
        case .open:
            return ("nopass", nil, false)

        case .wep(let key):
            guard isValidWEPKey(key) else {
                throw QRContentError.invalidWiFiCredential
            }

            return ("WEP", key, false)

        case .wpa(let password):
            guard isValidWPACredential(password) else {
                throw QRContentError.invalidWiFiCredential
            }

            return ("WPA", password, false)

        case .wpa3(let password):
            guard isValidSAEPassword(password) else {
                throw QRContentError.invalidWiFiCredential
            }

            return ("WPA", password, true)
        }
    }

    static func isValidWiFiSSID(_ ssid: String) -> Bool {
        (1...32).contains(ssid.utf8.count)
            && !containsDisallowedControls(ssid)
    }

    static func isValidWEPKey(_ key: String) -> Bool {
        switch key.utf8.count {
        case 5, 13:
            return isPrintableASCII(key)

        case 10, 26:
            return key.utf8.allSatisfy { isHexDigit($0) }

        default:
            return false
        }
    }

    static func isValidWPACredential(_ password: String) -> Bool {
        switch password.utf8.count {
        case 8...63:
            return isPrintableASCII(password)

        case 64:
            return password.utf8.allSatisfy { isHexDigit($0) }

        default:
            return false
        }
    }

    static func isValidSAEPassword(_ password: String) -> Bool {
        !password.isEmpty
            && !containsDisallowedControls(password)
    }

    static func containsDisallowedControls(_ value: String) -> Bool {
        let disallowedCharacters = CharacterSet.controlCharacters
            .union(.newlines)

        return value.unicodeScalars.contains {
            disallowedCharacters.contains($0)
        }
    }

    static func isPrintableASCII(_ value: String) -> Bool {
        value.utf8.allSatisfy { (0x20...0x7E).contains($0) }
    }

    static func isHexDigit(_ byte: UInt8) -> Bool {
        (0x30...0x39).contains(byte)
            || (0x41...0x46).contains(byte)
            || (0x61...0x66).contains(byte)
    }

    static func escapeWiFiField(_ value: String) -> String {
        var escaped = String()
        escaped.reserveCapacity(value.utf8.count)

        for scalar in value.unicodeScalars {
            switch scalar {
            case "\\", ";", ",", ":", "\"":
                escaped.append("\\")

            default:
                break
            }

            escaped.unicodeScalars.append(scalar)
        }

        return escaped
    }
}
