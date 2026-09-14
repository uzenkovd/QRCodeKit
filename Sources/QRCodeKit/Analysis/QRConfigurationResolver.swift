//
//  QRConfigurationResolver.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.09.2026.
//

struct QRConfigurationResolver {
    func resolve(
        for message: String,
        options: QROptions
    ) throws -> QRConfiguration {
        precondition(
            !message.isEmpty,
            "QR configuration cannot be resolved for an empty message"
        )

        let encodingMode = try resolveEncodingMode(
            for: message,
            requestedMode: options.encodingMode
        )

        let characterCount = try validatedCharacterCount(
            for: message,
            mode: encodingMode
        )

        let (version, errorCorrectionLevel) =
            try resolveVersionAndErrorCorrectionLevel(
                for: characterCount,
                mode: encodingMode,
                requestedVersion: options.version,
                requestedLevel: options.errorCorrectionLevel
            )

        // TODO: Defer automatic mask selection to the data masking stage.
        let mask = options.mask ?? .default

        return QRConfiguration(
            version: version,
            encodingMode: encodingMode,
            errorCorrectionLevel: errorCorrectionLevel,
            mask: mask
        )
    }
}

// MARK: - Encoding Mode

private extension QRConfigurationResolver {
    func resolveEncodingMode(
        for message: String,
        requestedMode: EncodingMode?
    ) throws -> EncodingMode {
        guard let recommendedMode = DataAnalyzer.recommendedEncodingMode(
            for: message
        ) else {
            throw QRCodeError.unsupportedMessage
        }

        guard let requestedMode else {
            return recommendedMode
        }

        guard requestedMode.canEncode(message) else {
            throw QRCodeError.wrongEncodingModeForMessage
        }

        return requestedMode
    }

    func validatedCharacterCount(
        for message: String,
        mode: EncodingMode
    ) throws -> Int {
        let characterCount = mode.characterCount(for: message)

        if DataAnalyzer.canFit(
            characterCount,
            mode: mode
        ) {
            return characterCount
        }

        let recommendedMode = recommendedEncodingMode(
            for: message
        )

        let recommendedCharacterCount =
            recommendedMode.characterCount(for: message)

        if DataAnalyzer.canFit(
            recommendedCharacterCount,
            mode: recommendedMode
        ) {
            throw QRCodeError.messageDoesNotFitEncodingMode
        }

        throw QRCodeError.messageIsTooLong
    }

    func recommendedEncodingMode(
        for message: String
    ) -> EncodingMode {
        guard let mode = DataAnalyzer.recommendedEncodingMode(
            for: message
        ) else {
            preconditionFailure(
                "Encodable message has no recommended encoding mode"
            )
        }

        return mode
    }
}

// MARK: - Version and Error Correction

private extension QRConfigurationResolver {
    func resolveVersionAndErrorCorrectionLevel(
        for characterCount: Int,
        mode: EncodingMode,
        requestedVersion: QRVersion?,
        requestedLevel: ErrorCorrectionLevel?
    ) throws -> (
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) {
        switch (requestedVersion, requestedLevel) {
        case let (version?, level?):
            guard DataAnalyzer.canFit(
                characterCount,
                mode: mode,
                version: version,
                errorCorrectionLevel: level
            ) else {
                throw QRCodeError.messageDoesNotFitQRConfiguration
            }

            return (version, level)

        case let (nil, level?):
            guard let version = DataAnalyzer.minimumVersion(
                for: characterCount,
                mode: mode,
                errorCorrectionLevel: level
            ) else {
                throw QRCodeError.messageDoesNotFitErrorCorrectionLevel
            }

            return (version, level)

        case let (version?, nil):
            guard let level = DataAnalyzer.strongestErrorCorrectionLevel(
                for: characterCount,
                mode: mode,
                version: version
            ) else {
                throw QRCodeError.messageDoesNotFitVersion
            }

            return (version, level)

        case (nil, nil):
            return resolveAutomaticVersionAndErrorCorrectionLevel(
                for: characterCount,
                mode: mode
            )
        }
    }

    func resolveAutomaticVersionAndErrorCorrectionLevel(
        for characterCount: Int,
        mode: EncodingMode
    ) -> (
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) {
        let fallbackLevels = ErrorCorrectionLevel.descendingOrder.drop(
            while: { $0 != .default }
        )

        var selectedVersion: QRVersion?

        for level in fallbackLevels {
            if let candidate = DataAnalyzer.minimumVersion(
                for: characterCount,
                mode: mode,
                errorCorrectionLevel: level
            ) {
                selectedVersion = candidate
                break
            }
        }

        guard let version = selectedVersion else {
            preconditionFailure(
                "Message fits QR capacity but no valid version was found"
            )
        }

        guard let level = DataAnalyzer.strongestErrorCorrectionLevel(
            for: characterCount,
            mode: mode,
            version: version
        ) else {
            preconditionFailure(
                "Recommended version has no fitting error correction level"
            )
        }

        return (version, level)
    }
}
