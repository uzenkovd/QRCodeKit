//
//  ConfigurationResolver.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.09.2026.
//

/// The pipeline step that resolves the configuration of a QR code
/// from the message and the requested options, choosing what the options
/// leave unspecified.
enum ConfigurationResolver {
    static func resolve(
        for message: String,
        options: QROptions
    ) throws -> QRConfiguration {
        guard let automaticMode = automaticEncodingMode(for: message) else {
            throw QRCodeError.unsupportedMessage
        }

        let mode = options.encodingMode ?? automaticMode

        guard mode.encoder.canEncode(message) else {
            throw QRCodeError.wrongEncodingModeForMessage
        }

        let characterCount = mode.encoder.characterCount(for: message)

        guard fitsMaximumCapacity(characterCount: characterCount, mode: mode) else {
            throw lengthError(for: message, automaticMode: automaticMode)
        }

        return try resolveConfiguration(
            characterCount: characterCount,
            mode: mode,
            requestedVersion: options.version,
            requestedLevel: options.errorCorrectionLevel
        )
    }
}

// MARK: - Encoding Mode

private extension ConfigurationResolver {
    /// The encoding modes in the order they are tried when none is requested.
    static let automaticEncodingModes: [QREncodingMode] = [
        .numeric,
        .alphanumeric,
        .kanji,
        .byte,
    ]

    /// Returns the first automatic encoding mode that can encode the message,
    /// or `nil` if no mode can encode it.
    static func automaticEncodingMode(
        for message: String
    ) -> QREncodingMode? {
        automaticEncodingModes.first { $0.encoder.canEncode(message) }
    }
}

// MARK: - Capacity

private extension ConfigurationResolver {
    /// Returns a Boolean value indicating whether a message with the given
    /// number of characters fits in the largest version at the lowest level.
    static func fitsMaximumCapacity(
        characterCount: Int,
        mode: QREncodingMode
    ) -> Bool {
        let configuration = QRConfiguration(
            version: .max,
            encodingMode: mode,
            errorCorrectionLevel: .min
        )

        return configuration.canFit(characterCount: characterCount)
    }

    /// Returns the error for a message that does not fit within the maximum capacity
    /// of its mode, depending on whether it fits within that of the automatic mode.
    static func lengthError(
        for message: String,
        automaticMode: QREncodingMode
    ) -> QRCodeError {
        let characterCount = automaticMode.encoder.characterCount(for: message)

        if fitsMaximumCapacity(characterCount: characterCount, mode: automaticMode) {
            return .messageDoesNotFitEncodingMode
        }

        return .messageIsTooLong
    }
}

// MARK: - Version and Error Correction Level

private extension ConfigurationResolver {
    /// Returns the configuration with the requested version and level,
    /// choosing the ones that are not requested.
    static func resolveConfiguration(
        characterCount: Int,
        mode: QREncodingMode,
        requestedVersion: QRVersion?,
        requestedLevel: QRErrorCorrectionLevel?
    ) throws -> QRConfiguration {
        switch (requestedVersion, requestedLevel) {
        case let (version?, level?):
            let configuration = QRConfiguration(
                version: version,
                encodingMode: mode,
                errorCorrectionLevel: level
            )

            guard configuration.canFit(characterCount: characterCount) else {
                throw QRCodeError.messageDoesNotFitQRConfiguration
            }

            return configuration

        case let (nil, level?):
            guard
                let configuration = smallestConfiguration(
                    fitting: characterCount,
                    mode: mode,
                    level: level
                )
            else {
                throw QRCodeError.messageDoesNotFitErrorCorrectionLevel
            }

            return configuration

        case let (version?, nil):
            guard
                let configuration = strongestConfiguration(
                    fitting: characterCount,
                    mode: mode,
                    version: version
                )
            else {
                throw QRCodeError.messageDoesNotFitVersion
            }

            return configuration

        case (nil, nil):
            return automaticConfiguration(fitting: characterCount, mode: mode)
        }
    }

    /// Returns the configuration with the smallest version that fits
    /// the message at the given level, or `nil` if no version fits it.
    static func smallestConfiguration(
        fitting characterCount: Int,
        mode: QREncodingMode,
        level: QRErrorCorrectionLevel
    ) -> QRConfiguration? {
        let candidates = QRVersion.allCases.lazy.map { version in
            QRConfiguration(version: version, encodingMode: mode, errorCorrectionLevel: level)
        }

        return candidates.first { $0.canFit(characterCount: characterCount) }
    }

    /// Returns the configuration with the strongest level that fits
    /// the message in the given version, or `nil` if no level fits it.
    static func strongestConfiguration(
        fitting characterCount: Int,
        mode: QREncodingMode,
        version: QRVersion
    ) -> QRConfiguration? {
        let candidates = QRErrorCorrectionLevel.descendingOrder.lazy.map { level in
            QRConfiguration(version: version, encodingMode: mode, errorCorrectionLevel: level)
        }

        return candidates.first { $0.canFit(characterCount: characterCount) }
    }

    /// Returns the configuration with the smallest version that fits the
    /// message at the default level, or below it if necessary, raised to
    /// the strongest level that still fits that version.
    static func automaticConfiguration(
        fitting characterCount: Int,
        mode: QREncodingMode
    ) -> QRConfiguration {
        let levelsFromDefault = QRErrorCorrectionLevel.descendingOrder
            .drop(while: { $0 != .default })

        for level in levelsFromDefault {
            let smallest = smallestConfiguration(fitting: characterCount, mode: mode, level: level)

            if let smallest {
                let strongest = strongestConfiguration(
                    fitting: characterCount,
                    mode: mode,
                    version: smallest.version
                )

                return strongest ?? smallest
            }
        }

        preconditionFailure("Message fits the maximum capacity but no configuration fits it")
    }
}
