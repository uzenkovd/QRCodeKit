//
//  DataEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.08.2026.
//

struct DataEncoder {
    // TODO: Consider introducing EncodingResult to expose the individual encoding components.
    func encode(
        _ message: String,
        mode: EncodingMode,
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> [UInt8] {
        let modeIndicator = mode.indicator
        let modeIndicatorBitCount = 4

        let characterCountIndicator = UInt32(
            mode.characterCount(for: message)
        )
        let characterCountIndicatorBitCount = CharacterCountIndicator.bitCount(
            for: version,
            mode: mode
        )

        let encodedData = encodeData(message, mode: mode)

        let totalDataCodewords = ErrorCorrectionBlocks.totalDataCodewordCount(
            for: version,
            level: errorCorrectionLevel
        )

        let totalDataBits = totalDataCodewords * 8
        var currentDataBits = (
            modeIndicatorBitCount +
            characterCountIndicatorBitCount +
            encodedData.count
        )

        precondition(
            currentDataBits <= totalDataBits,
            "Encoded data exceeds the selected version and error correction level capacity"
        )

        let remainingDataBits = totalDataBits - currentDataBits
        let terminatorBitCount = min(4, remainingDataBits)

        currentDataBits += terminatorBitCount

        let byteAlignmentBitCount = (8 - currentDataBits % 8) % 8

        currentDataBits += byteAlignmentBitCount

        let padByteCount = (totalDataBits - currentDataBits) / 8
        let padBytes = makePadBytes(count: padByteCount)

        var buffer = BitBuffer()

        buffer.append(modeIndicator, bitCount: modeIndicatorBitCount)
        buffer.append(characterCountIndicator, bitCount: characterCountIndicatorBitCount)
        buffer.append(contentsOf: encodedData)
        buffer.append(0, bitCount: terminatorBitCount)
        buffer.append(0, bitCount: byteAlignmentBitCount)
        buffer.append(contentsOf: padBytes)

        assert(
            buffer.count == totalDataBits,
            "Encoded data does not match the expected data capacity"
        )

        return buffer.bytes
    }
}

// MARK: - Encoding Helpers

private extension DataEncoder {
    func encodeData(
        _ message: String,
        mode: EncodingMode
    ) -> BitBuffer {
        switch mode {
        case .numeric:      NumericEncoder.encode(message)
        case .alphanumeric: AlphanumericEncoder.encode(message)
        case .kanji:        KanjiEncoder.encode(message)
        case .byte:         ByteEncoder.encode(message)
        }
    }

    func makePadBytes(count: Int) -> BitBuffer {
        let padByteValues: [UInt8] = [0xEC, 0x11]
        var buffer = BitBuffer()

        for index in 0..<count {
            let byte = padByteValues[index % padByteValues.count]
            buffer.append(byte)
        }

        return buffer
    }
}
