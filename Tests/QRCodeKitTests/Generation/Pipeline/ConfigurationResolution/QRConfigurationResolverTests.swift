//
//  QRConfigurationResolverTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 13.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRConfigurationResolverTests {
    // MARK: - Encoding Mode

    @Test(arguments: [
        ("0123456789", .numeric),
        ("HELLO WORLD", .alphanumeric),
        ("Café", .byte),
        ("日本語", .kanji)
    ] as [(String, EncodingMode)])
    func usesAutomaticEncodingModeWhenNoneIsRequested(
        message: String,
        expectedMode: EncodingMode
    ) throws {
        let configuration = try QRConfigurationResolver.resolve(for: message, options: QROptions())

        #expect(configuration.encodingMode == expectedMode)
    }

    @Test
    func usesRequestedEncodingMode() throws {
        let options = QROptions(encodingMode: .byte)

        let configuration = try QRConfigurationResolver.resolve(for: "12345", options: options)

        #expect(configuration.encodingMode == .byte)
    }

    @Test
    func throwsUnsupportedMessageWhenNoModeCanEncodeMessage() {
        #expect(throws: QRCodeError.unsupportedMessage) {
            try QRConfigurationResolver.resolve(for: "🙂", options: QROptions())
        }
    }

    @Test
    func throwsWrongEncodingModeWhenRequestedModeCannotEncodeMessage() {
        let options = QROptions(encodingMode: .numeric)

        #expect(throws: QRCodeError.wrongEncodingModeForMessage) {
            try QRConfigurationResolver.resolve(for: "ABC", options: options)
        }
    }

    // MARK: - Capacity

    @Test
    func throwsMessageDoesNotFitEncodingModeWhenAutomaticModeFits() {
        let capacity = CharacterCapacityTable.capacity(for: .v40, level: .L, mode: .byte)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(encodingMode: .byte)

        #expect(throws: QRCodeError.messageDoesNotFitEncodingMode) {
            try QRConfigurationResolver.resolve(for: message, options: options)
        }
    }

    @Test
    func throwsMessageIsTooLongWhenAutomaticModeCannotFit() {
        let capacity = CharacterCapacityTable.capacity(for: .v40, level: .L, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)

        #expect(throws: QRCodeError.messageIsTooLong) {
            try QRConfigurationResolver.resolve(for: message, options: QROptions())
        }
    }

    @Test
    func throwsMessageIsTooLongWhenRequestedModeIsAutomaticMode() {
        let capacity = CharacterCapacityTable.capacity(for: .v40, level: .L, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(encodingMode: .alphanumeric)

        #expect(throws: QRCodeError.messageIsTooLong) {
            try QRConfigurationResolver.resolve(for: message, options: options)
        }
    }

    // MARK: - Version and Error Correction Level

    @Test
    func usesRequestedVersionAndLevel() throws {
        let message = String(repeating: "A", count: 10)
        let options = QROptions(version: .v2, errorCorrectionLevel: .M)

        let configuration = try QRConfigurationResolver.resolve(for: message, options: options)

        #expect(configuration.version == .v2)
        #expect(configuration.errorCorrectionLevel == .M)
    }

    @Test
    func throwsMessageDoesNotFitQRConfigurationWhenRequestedOneCannotFit() {
        let capacity = CharacterCapacityTable.capacity(for: .v1, level: .M, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(version: .v1, errorCorrectionLevel: .M)

        #expect(throws: QRCodeError.messageDoesNotFitQRConfiguration) {
            try QRConfigurationResolver.resolve(for: message, options: options)
        }
    }

    @Test
    func usesSmallestVersionForRequestedLevel() throws {
        let capacity = CharacterCapacityTable.capacity(for: .v1, level: .M, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(errorCorrectionLevel: .M)

        let configuration = try QRConfigurationResolver.resolve(for: message, options: options)

        #expect(configuration.version == .v2)
        #expect(configuration.errorCorrectionLevel == .M)
    }

    @Test
    func throwsMessageDoesNotFitErrorCorrectionLevelWhenNoVersionCanFit() {
        let capacity = CharacterCapacityTable.capacity(for: .v40, level: .Q, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(errorCorrectionLevel: .Q)

        #expect(throws: QRCodeError.messageDoesNotFitErrorCorrectionLevel) {
            try QRConfigurationResolver.resolve(for: message, options: options)
        }
    }

    @Test
    func usesStrongestLevelForRequestedVersion() throws {
        let capacity = CharacterCapacityTable.capacity(for: .v1, level: .H, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(version: .v1)

        let configuration = try QRConfigurationResolver.resolve(for: message, options: options)

        #expect(configuration.version == .v1)
        #expect(configuration.errorCorrectionLevel == .Q)
    }

    @Test
    func throwsMessageDoesNotFitVersionWhenNoLevelCanFit() {
        let capacity = CharacterCapacityTable.capacity(for: .v1, level: .L, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)
        let options = QROptions(version: .v1)

        #expect(throws: QRCodeError.messageDoesNotFitVersion) {
            try QRConfigurationResolver.resolve(for: message, options: options)
        }
    }

    // MARK: - Automatic Version and Error Correction Level

    @Test
    func raisesLevelWithinSmallestVersion() throws {
        let capacity = CharacterCapacityTable.capacity(for: .v1, level: .H, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity)

        let configuration = try QRConfigurationResolver.resolve(for: message, options: QROptions())

        #expect(configuration.version == .v1)
        #expect(configuration.errorCorrectionLevel == .H)
    }

    @Test
    func prefersDefaultLevelOverSmallerVersion() throws {
        let capacity = CharacterCapacityTable.capacity(for: .v1, level: .M, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)

        let configuration = try QRConfigurationResolver.resolve(for: message, options: QROptions())

        #expect(configuration.version == .v2)
        #expect(configuration.errorCorrectionLevel == .Q)
    }

    @Test
    func fallsBelowDefaultLevelWhenNoVersionFitsIt() throws {
        let capacity = CharacterCapacityTable.capacity(for: .v40, level: .M, mode: .alphanumeric)
        let message = String(repeating: "A", count: capacity + 1)

        let configuration = try QRConfigurationResolver.resolve(for: message, options: QROptions())

        #expect(configuration.version == .v36)
        #expect(configuration.errorCorrectionLevel == .L)
    }
}
