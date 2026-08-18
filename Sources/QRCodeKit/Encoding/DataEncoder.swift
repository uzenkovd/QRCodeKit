//
//  DataEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.08.2026.
//

struct DataEncoder {
    func encode(
        _ message: String,
        mode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel,
        version: QRVersion
    ) -> [UInt8] {
        let modeIndicator = mode.indicator
        
        let characterCountIndicator = UInt32(message.count)
        let characterCountIndicatorLength = CharacterCountIndicatorLengths.length(
            for: version,
            mode: mode
        )
        
        var bitBuffer = BitBuffer()
        
        bitBuffer.append(modeIndicator, bitCount: 4)
        bitBuffer.append(
            characterCountIndicator,
            bitCount: characterCountIndicatorLength
        )
        
        return bitBuffer.bytes
    }
}
