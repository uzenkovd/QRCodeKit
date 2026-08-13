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
        
        let analyzer = DataAnalyzer()
        guard analyzer.canEncode(message) else {
            throw QRCodeError.unsupportedMessage
        }
        
        let errorCorrectionLevel = options.errorCorrectionLevel ?? .default
        
        //let recommendedEncodingMode =
        //if let encodingMode = options.encodingMode ??
        
        let encodingMode = options.encodingMode ?? .byte
        let version = options.version ?? .v1
        let mask = options.mask ?? .pattern0
        
        self.message = message
        self.version = version
        self.encodingMode = encodingMode
        self.errorCorrectionLevel = errorCorrectionLevel
        self.mask = mask
    }
}
