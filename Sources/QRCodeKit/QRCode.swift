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
        
        guard EncodingMode.recommended(for: message) != nil else {
            throw QRCodeError.noAppropriateEncodingMode
        }
        
        let errorCorrectionLevel = options.errorCorrectionLevel ?? .default
                
        let encodingMode: EncodingMode
        if let option = options.encodingMode {
            encodingMode = option
        } else {
            guard let recommended = EncodingMode.recommended(for: message) else {
                throw QRCodeError.noAppropriateEncodingMode
            }
            
            encodingMode = recommended
        }
        
//        let dataAnalyzer = DataAnalyzer()
        
//        let version: QRVersion
//        if let option = options.version {
//            //guard let
//        } else {
//            guard let recommended = dataAnalyzer.recommendedVersion(
//                for: message,
//                with: encodingMode,
//                and: errorCorrectionLevel) else {
//                throw QRCodeError.emptyMessage
//            }
//        }
            
        let version = options.version ?? .v1
        let mask = options.mask ?? .pattern0
        
        self.message = message
        self.version = version
        self.encodingMode = encodingMode
        self.errorCorrectionLevel = errorCorrectionLevel
        self.mask = mask
    }
}
