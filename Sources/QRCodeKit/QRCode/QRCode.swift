//
//  QRCode.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.08.2026.
//

public struct QRCode {
    public let message: String
    public let version: QRVersion
    public let encodingMode: EncodingMode
    public let errorCorrectionLevel: ErrorCorrectionLevel
    
    public private(set) var mask: QRMask
    
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
        
        let dataAnalyzer = DataAnalyzer()
        
        guard dataAnalyzer.canEncode(message) else {
            throw QRCodeError.unsupportedMessage
        }
        
        let encodingMode: EncodingMode
        if let optionMode = options.encodingMode {
            guard optionMode.canEncode(message) else {
                throw QRCodeError.wrongEncodingModeForMessage
            }
            
            encodingMode = optionMode
        } else {
            guard let recommended = dataAnalyzer.recommendedEncodingMode(
                for: message
            ) else {
                preconditionFailure(
                    "Supported message has no recommended encoding mode"
                )
            }
            
            encodingMode = recommended
        }
        
        let characterCount = encodingMode.characterCount(for: message)
        
        guard dataAnalyzer.canFit(
            characterCount,
            mode: encodingMode
        ) else {
            throw QRCodeError.messageIsTooLong
        }
        
        let version: QRVersion
        let errorCorrectionLevel: ErrorCorrectionLevel
        
        switch (options.version, options.errorCorrectionLevel) {
        case let (optionVersion?, optionLevel?):
            guard dataAnalyzer.canFit(
                characterCount,
                mode: encodingMode,
                errorCorrectionLevel: optionLevel,
                version: optionVersion
            ) else {
                throw QRCodeError.messageDoesNotFitQRConfiguration
            }
            
            version = optionVersion
            errorCorrectionLevel = optionLevel
            
        case let (nil, optionLevel?):
            guard let recommendedVersion = dataAnalyzer.recommendedVersion(
                for: characterCount,
                mode: encodingMode,
                errorCorrectionLevel: optionLevel
            ) else {
                throw QRCodeError.messageDoesNotFitErrorCorrectionLevel
            }
            
            version = recommendedVersion
            errorCorrectionLevel = optionLevel
            
        case let (optionVersion?, nil):
            guard let recommendedLevel =
                    dataAnalyzer.recommendedErrorCorrectionLevel(
                        for: characterCount,
                        mode: encodingMode,
                        version: optionVersion
                    )
            else {
                throw QRCodeError.messageDoesNotFitVersion
            }
            
            version = optionVersion
            errorCorrectionLevel = recommendedLevel
            
        case (nil, nil):
            let fallbackLevels = ErrorCorrectionLevel.descendingOrder.drop(
                while: { $0 != .default }
            )
            
            var recommendedVersion: QRVersion?
            
            for level in fallbackLevels {
                if let candidate = dataAnalyzer.recommendedVersion(
                    for: characterCount,
                    mode: encodingMode,
                    errorCorrectionLevel: level
                ) {
                    recommendedVersion = candidate
                    break
                }
            }
            
            guard let recommendedVersion else {
                preconditionFailure(
                    "Fittable message has no valid version"
                )
            }
            
            guard let recommendedLevel =
                    dataAnalyzer.recommendedErrorCorrectionLevel(
                        for: characterCount,
                        mode: encodingMode,
                        version: recommendedVersion
                    )
            else {
                preconditionFailure(
                    "Recommended version cannot fit the message"
                )
            }
            
            version = recommendedVersion
            errorCorrectionLevel = recommendedLevel
        }
        
        let mask = options.mask ?? .default
        
        self.message = message
        self.version = version
        self.encodingMode = encodingMode
        self.errorCorrectionLevel = errorCorrectionLevel
        self.mask = mask
    }
}
