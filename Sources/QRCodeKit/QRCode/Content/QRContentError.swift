//
//  QRContentError.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 09.10.2026.
//

public enum QRContentError: Error {
    case invalidPhoneNumber

    case invalidEmailAddress
    case invalidEmailSubject

    case invalidGeolocation

    case invalidWiFiSSID
    case invalidWiFiCredential
}
