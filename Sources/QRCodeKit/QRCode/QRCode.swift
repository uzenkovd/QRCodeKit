//
//  QRCode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.08.2026.
//

public struct QRCode {
    public let message: String

    private var configuration: QRConfiguration
    private let codewordGroups: CodewordGroups

    public var version: QRVersion {
        configuration.version
    }

    public var encodingMode: EncodingMode {
        configuration.encodingMode
    }

    public var errorCorrectionLevel: ErrorCorrectionLevel {
        configuration.errorCorrectionLevel
    }

    public var mask: QRMask {
        guard let mask = configuration.mask else {
            preconditionFailure(
                "QR mask must be resolved before accessing it"
            )
        }

        return mask
    }

    public var size: Int {
        21 + 4 * (version.rawValue - 1)
    }

    public init(
        _ message: String,
        options: QROptions = QROptions()
    ) throws {
        guard !message.isEmpty else {
            throw QRCodeError.emptyMessage
        }

        let configuration = try QRConfigurationResolver().resolve(
            for: message,
            options: options
        )

        let dataCodewords = DataEncoder().encode(
            message,
            mode: configuration.encodingMode,
            version: configuration.version,
            errorCorrectionLevel: configuration.errorCorrectionLevel
        )

        let codewordGroups = CodewordGroupsBuilder.build(
            from: dataCodewords,
            layout: configuration.errorCorrectionLayout
        )

        self.message = message
        self.configuration = configuration
        self.codewordGroups = codewordGroups
    }
}
