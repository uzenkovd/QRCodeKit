//
//  QRConfigurationResolver.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.09.2026.
//

struct QRConfigurationResolver {
    static func resolve(
        for message: String,
        options: QROptions
    ) throws -> QRConfiguration {
        let analyzer = DataAnalyzer()

        let encodingMode = try resolveEncodingMode(
            for: message,
            requestedMode: options.encodingMode,
            analyzer: analyzer
        )

        let characterCount = try validatedCharacterCount(
            for: message,
            mode: encodingMode,
            analyzer: analyzer
        )

        let (version, errorCorrectionLevel) =
            try resolveVersionAndErrorCorrectionLevel(
                for: characterCount,
                mode: encodingMode,
                requestedVersion: options.version,
                requestedLevel: options.errorCorrectionLevel,
                analyzer: analyzer
            )

        // TODO: Select the optimal mask automatically when no mask is specified.
        let mask = options.mask ?? .default

        return QRConfiguration(
            version: version,
            encodingMode: encodingMode,
            errorCorrectionLevel: errorCorrectionLevel,
            mask: mask
        )
    }
}

private extension QRConfigurationResolver {
    static func resolveEncodingMode(
        for message: String,
        requestedMode: EncodingMode?,
        analyzer: DataAnalyzer
    ) throws -> EncodingMode {
        guard analyzer.canEncode(message) else {
            throw QRCodeError.unsupportedMessage
        }

        if let requestedMode {
            guard requestedMode.canEncode(message) else {
                throw QRCodeError.wrongEncodingModeForMessage
            }

            return requestedMode
        }

        guard let recommendedMode = analyzer.recommendedEncodingMode(
            for: message
        ) else {
            preconditionFailure(
                "Supported message has no recommended encoding mode"
            )
        }

        return recommendedMode
    }

    static func validatedCharacterCount(
        for message: String,
        mode: EncodingMode,
        analyzer: DataAnalyzer
    ) throws -> Int {
        let characterCount = mode.characterCount(for: message)

        // TODO: Distinguish an inefficient explicitly selected encoding mode
        // from an oversized message.
        guard analyzer.canFit(
            characterCount,
            mode: mode
        ) else {
            throw QRCodeError.messageIsTooLong
        }

        return characterCount
    }

    static func resolveVersionAndErrorCorrectionLevel(
        for characterCount: Int,
        mode: EncodingMode,
        requestedVersion: QRVersion?,
        requestedLevel: ErrorCorrectionLevel?,
        analyzer: DataAnalyzer
    ) throws -> (
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) {
        switch (requestedVersion, requestedLevel) {
        case let (version?, level?):
            guard analyzer.canFit(
                characterCount,
                mode: mode,
                errorCorrectionLevel: level,
                version: version
            ) else {
                throw QRCodeError.messageDoesNotFitQRConfiguration
            }

            return (version, level)

        case let (nil, level?):
            guard let version = analyzer.recommendedVersion(
                for: characterCount,
                mode: mode,
                errorCorrectionLevel: level
            ) else {
                throw QRCodeError.messageDoesNotFitErrorCorrectionLevel
            }

            return (version, level)

        case let (version?, nil):
            guard let level = analyzer.recommendedErrorCorrectionLevel(
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
                mode: mode,
                analyzer: analyzer
            )
        }
    }

    static func resolveAutomaticVersionAndErrorCorrectionLevel(
        for characterCount: Int,
        mode: EncodingMode,
        analyzer: DataAnalyzer
    ) -> (
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) {
        let fallbackLevels = ErrorCorrectionLevel.descendingOrder.drop(
            while: { $0 != .default }
        )

        var recommendedVersion: QRVersion?

        for level in fallbackLevels {
            if let candidate = analyzer.recommendedVersion(
                for: characterCount,
                mode: mode,
                errorCorrectionLevel: level
            ) {
                recommendedVersion = candidate
                break
            }
        }

        guard let version = recommendedVersion else {
            preconditionFailure(
                "Fittable message has no valid version"
            )
        }

        guard let level = analyzer.recommendedErrorCorrectionLevel(
            for: characterCount,
            mode: mode,
            version: version
        ) else {
            preconditionFailure(
                "Recommended version cannot fit the message"
            )
        }

        return (version, level)
    }
}
