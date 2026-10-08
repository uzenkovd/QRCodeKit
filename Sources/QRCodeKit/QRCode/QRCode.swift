//
//  QRCode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.08.2026.
//

public struct QRCode {
    private let content: QRContent
    private let configuration: QRConfiguration
    private let codewordGroups: CodewordGroups

    let symbol: QRSymbol

    public var message: String {
        content.payload
    }

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
        try self.init(
            QRContent.text(message),
            options: options
        )
    }

    public init(
        _ content: QRContent,
        options: QROptions = QROptions()
    ) throws {
        guard !content.payload.isEmpty else {
            throw QRCodeError.emptyMessage
        }

        let configuration = try QRConfigurationResolver.resolve(
            for: content.payload,
            options: options
        )

        let dataCodewords = DataEncoder.encode(
            content.payload,
            using: configuration
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

        self.content = content
        self.configuration = configuration
        self.codewordGroups = codewordGroups
        self.symbol = symbol
    }
}
