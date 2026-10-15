//
//  QRContent+Geo.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Foundation

public extension QRContent {
    static func geo(
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil,
        uncertainty: Double? = nil
    ) throws -> QRContent {
        guard
            latitude.isFinite,
            (-90.0...90.0).contains(latitude),
            longitude.isFinite,
            (-180.0...180.0).contains(longitude),
            altitude.map(\.isFinite) ?? true,
            uncertainty.map({ $0.isFinite && $0 >= 0 }) ?? true
        else {
            throw QRContentError.invalidGeolocation
        }

        var payload = "geo:\(formatGeoNumber(latitude)),\(formatGeoNumber(longitude))"

        if let altitude {
            payload += ",\(formatGeoNumber(altitude))"
        }

        if let uncertainty {
            payload += ";u=\(formatGeoNumber(uncertainty))"
        }

        return QRContent(payload: payload)
    }
}

// MARK: - Private Helpers

private extension QRContent {
    static func formatGeoNumber(_ value: Double) -> String {
        precondition(value.isFinite)

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.usesSignificantDigits = true
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 17

        let normalized = value == 0 ? 0.0 : value

        guard let formatted = formatter.string(
            from: NSNumber(value: normalized)
        ) else {
            preconditionFailure("Failed to format geolocation number")
        }

        return formatted
    }
}
