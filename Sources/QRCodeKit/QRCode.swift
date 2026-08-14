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
        
        let errorCorrectionLevel = options.errorCorrectionLevel ?? .default
        
        let encodingMode: EncodingMode
        if let option = options.encodingMode {
            guard option.canEncode(message) else {
                throw QRCodeError.wrongEncodingModeForMessage
            }
            
            encodingMode = option
        } else {
            guard let recommended = dataAnalyzer.recommendedEncodingMode(for: message) else {
                throw QRCodeError.noAppropriateEncodingMode
            }
            
            encodingMode = recommended
        }
        
        guard dataAnalyzer.canFit(
            message: message,
            encodingMode: encodingMode
        ) else {
            throw QRCodeError.messageIsTooLong
        }
        
        let version: QRVersion
        if let option = options.version {
            guard dataAnalyzer.canFit(
                message: message,
                encodingMode: encodingMode,
                errorCorrectionLevel: errorCorrectionLevel,
                version: option
            ) else {
                throw QRCodeError.wrongVersionForQRConfiguration
            }
            
            version = option
        } else {
            guard let recommended = dataAnalyzer.recommendedVersion(
                message: message,
                encodingMode: encodingMode,
                errorCorrectionLevel: errorCorrectionLevel
            ) else {
                throw QRCodeError.messageIsTooLong
            }
            
            version = recommended
        }
        
        let mask = options.mask ?? .default
        
        self.message = message
        self.version = version
        self.encodingMode = encodingMode
        self.errorCorrectionLevel = errorCorrectionLevel
        self.mask = mask
    }
}
