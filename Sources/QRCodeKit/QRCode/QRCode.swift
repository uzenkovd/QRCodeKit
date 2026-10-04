//
//  QRCode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.08.2026.
//

public struct QRCode {
    public let message: String

    let symbol: QRSymbol

    private let configuration: QRConfiguration
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
        symbol.mask
    }

    public var size: Int {
        symbol.size
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

        let finalMessage = FinalMessageBuilder.build(
            from: codewordGroups,
            version: configuration.version
        )

        let matrix = ModulePlacer.place(
            finalMessage,
            version: configuration.version
        )

        let symbol = DataMasker.apply(
            to: matrix,
            version: configuration.version,
            errorCorrectionLevel: configuration.errorCorrectionLevel,
            requestedMask: options.mask
        )

        self.message = message
        self.symbol = symbol
        self.configuration = configuration
        self.codewordGroups = codewordGroups
    }
}
