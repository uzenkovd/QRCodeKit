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
        ("0123456789", EncodingMode.numeric),
        ("HELLO WORLD", EncodingMode.alphanumeric),
        ("日本語", EncodingMode.kanji),
        ("Café", EncodingMode.byte)
    ])
    func usesRecommendedEncodingModeWhenNotSpecified(
        message: String,
        expectedMode: EncodingMode
    ) throws {
        let options = QROptions()

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.encodingMode == expectedMode)
    }

    @Test
    func usesRequestedEncodingModeWhenValid() throws {
        let message = "12345"
        let options = QROptions(
            encodingMode: .byte
        )

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.encodingMode == .byte)
    }

    @Test
    func throwsUnsupportedMessageForUnencodableMessage() {
        let message = "🙂𠜎"
        let options = QROptions()

        #expect(throws: QRCodeError.unsupportedMessage) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func throwsWrongEncodingModeForIncompatibleRequestedMode() {
        let message = "ABC"
        let options = QROptions(
            encodingMode: .numeric
        )

        #expect(throws: QRCodeError.wrongEncodingModeForMessage) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func throwsMessageDoesNotFitEncodingModeWhenRecommendedModeFits() {
        let maximumByteCapacity = 2953
        let message = String(
            repeating: "A",
            count: maximumByteCapacity + 1
        )
        let options = QROptions(
            encodingMode: .byte
        )

        #expect(throws: QRCodeError.messageDoesNotFitEncodingMode) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func throwsMessageIsTooLongWhenRecommendedModeCannotFit() {
        let maximumAlphanumericCapacity = 4296
        let message = String(
            repeating: "A",
            count: maximumAlphanumericCapacity + 1
        )
        let options = QROptions()

        #expect(throws: QRCodeError.messageIsTooLong) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func throwsMessageIsTooLongWhenRequestedModeIsAlreadyRecommended() {
        let maximumAlphanumericCapacity = 4296
        let message = String(
            repeating: "A",
            count: maximumAlphanumericCapacity + 1
        )
        let options = QROptions(
            encodingMode: .alphanumeric
        )

        #expect(throws: QRCodeError.messageIsTooLong) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    // MARK: - Version and Error Correction

    @Test
    func usesRequestedVersionAndErrorCorrectionLevelWhenValid() throws {
        let message = String(repeating: "A", count: 10)
        let options = QROptions(
            version: .v2,
            errorCorrectionLevel: .M
        )

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.version == .v2)
        #expect(configuration.errorCorrectionLevel == .M)
    }

    @Test
    func throwsMessageDoesNotFitQRConfigurationWhenRequestedConfigurationCannotFit() {
        let maximumV1MAlphanumericCapacity = 20
        let message = String(
            repeating: "A",
            count: maximumV1MAlphanumericCapacity + 1
        )
        let options = QROptions(
            version: .v1,
            errorCorrectionLevel: .M
        )

        #expect(throws: QRCodeError.messageDoesNotFitQRConfiguration) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func usesMinimumVersionForRequestedErrorCorrectionLevel() throws {
        let maximumV1MAlphanumericCapacity = 20
        let message = String(
            repeating: "A",
            count: maximumV1MAlphanumericCapacity + 1
        )
        let options = QROptions(
            errorCorrectionLevel: .M
        )

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.version == .v2)
        #expect(configuration.errorCorrectionLevel == .M)
    }

    @Test
    func throwsMessageDoesNotFitErrorCorrectionLevelWhenNoVersionCanFit() {
        let maximumQAlphanumericCapacity = 2420
        let message = String(
            repeating: "A",
            count: maximumQAlphanumericCapacity + 1
        )
        let options = QROptions(
            errorCorrectionLevel: .Q
        )

        #expect(throws: QRCodeError.messageDoesNotFitErrorCorrectionLevel) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func usesStrongestFittingErrorCorrectionLevelForRequestedVersion() throws {
        let maximumV1HAlphanumericCapacity = 10
        let message = String(
            repeating: "A",
            count: maximumV1HAlphanumericCapacity + 1
        )
        let options = QROptions(
            version: .v1
        )

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.version == .v1)
        #expect(configuration.errorCorrectionLevel == .Q)
    }

    @Test
    func throwsMessageDoesNotFitVersionWhenNoErrorCorrectionLevelCanFit() {
        let maximumV1LAlphanumericCapacity = 25
        let message = String(
            repeating: "A",
            count: maximumV1LAlphanumericCapacity + 1
        )
        let options = QROptions(
            version: .v1
        )

        #expect(throws: QRCodeError.messageDoesNotFitVersion) {
            try QRConfigurationResolver.resolve(
                for: message,
                options: options
            )
        }
    }

    @Test
    func usesStrongestErrorCorrectionLevelWithinMinimumVersion() throws {
        let maximumV1HAlphanumericCapacity = 10
        let message = String(
            repeating: "A",
            count: maximumV1HAlphanumericCapacity
        )
        let options = QROptions()

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.version == .v1)
        #expect(configuration.errorCorrectionLevel == .H)
    }

    @Test
    func prefersDefaultErrorCorrectionLevelOverSmallerVersion() throws {
        let maximumV1MAlphanumericCapacity = 20
        let message = String(
            repeating: "A",
            count: maximumV1MAlphanumericCapacity + 1
        )
        let options = QROptions()

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.version == .v2)
        #expect(configuration.errorCorrectionLevel == .Q)
    }

    @Test
    func fallsBackBelowDefaultErrorCorrectionLevelWhenNecessary() throws {
        let maximumMAlphanumericCapacity = 3391
        let message = String(
            repeating: "A",
            count: maximumMAlphanumericCapacity + 1
        )
        let options = QROptions()

        let configuration = try QRConfigurationResolver.resolve(
            for: message,
            options: options
        )

        #expect(configuration.version == .v36)
        #expect(configuration.errorCorrectionLevel == .L)
    }
}
