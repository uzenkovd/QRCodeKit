//
//  QRCode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.08.2026.
//

public struct QRCode {
    private let content: QRContent
    private let configuration: QRConfiguration
    private let symbol: QRSymbol

    var matrix: QRMatrix {
        symbol.matrix
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

        let symbol = SymbolFinalizer.finalize(
            matrix,
            version: configuration.version,
            errorCorrectionLevel: configuration.errorCorrectionLevel,
            requestedMask: options.mask
        )

        self.content = content
        self.configuration = configuration
        self.symbol = symbol
    }
}

// MARK: - Public Properties

public extension QRCode {
    var message: String {
        content.payload
    }

    var version: QRVersion {
        configuration.version
    }

    var encodingMode: EncodingMode {
        configuration.encodingMode
    }

    var errorCorrectionLevel: ErrorCorrectionLevel {
        configuration.errorCorrectionLevel
    }

    var mask: QRMask {
        symbol.mask
    }

    var size: Int {
        symbol.size
    }
}
