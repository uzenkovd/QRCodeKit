//
//  DataEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.08.2026.
//

enum DataEncoder {
    static func encode(
        _ message: String,
        using configuration: QRConfiguration
    ) -> [UInt8] {
        let mode = configuration.encodingMode

        let modeIndicator = mode.indicator
        let modeIndicatorBitCount = 4

        let characterCountIndicator = UInt32(
            mode.characterCount(for: message)
        )
        let characterCountIndicatorBitCount =
            CharacterCountIndicator.bitCount(
                for: configuration.version,
                mode: mode
            )

        let encodedData = encodeData(
            message,
            mode: mode
        )

        let totalDataCodewordCount =
            configuration.errorCorrectionLayout.totalDataCodewordCount
        let totalDataBitCount = totalDataCodewordCount * 8

        var currentDataBitCount =
            modeIndicatorBitCount
            + characterCountIndicatorBitCount
            + encodedData.count

        precondition(
            currentDataBitCount <= totalDataBitCount,
            "Encoded data exceeds the selected version and error correction level capacity"
        )

        let remainingDataBitCount = totalDataBitCount - currentDataBitCount
        let terminatorBitCount = min(
            4,
            remainingDataBitCount
        )

        currentDataBitCount += terminatorBitCount

        let byteAlignmentBitCount = (8 - currentDataBitCount % 8) % 8

        currentDataBitCount += byteAlignmentBitCount

        let padCodewordCount = (totalDataBitCount - currentDataBitCount) / 8

        var buffer = BitBuffer(minimumCapacity: totalDataBitCount)

        buffer.append(
            modeIndicator,
            bitCount: modeIndicatorBitCount
        )
        buffer.append(
            characterCountIndicator,
            bitCount: characterCountIndicatorBitCount
        )
        buffer.append(contentsOf: encodedData)
        buffer.append(0, bitCount: terminatorBitCount)
        buffer.append(0, bitCount: byteAlignmentBitCount)

        appendPadCodewords(
            count: padCodewordCount,
            to: &buffer
        )

        assert(
            buffer.count == totalDataBitCount,
            "Encoded data does not match the expected data capacity"
        )

        return buffer.bytes
    }
}

// MARK: - Encoding Helpers

private extension DataEncoder {
    static func encodeData(
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

    static func appendPadCodewords(
        count: Int,
        to buffer: inout BitBuffer
    ) {
        precondition(
            buffer.isAligned,
            "Pad codewords can only be appended to byte-aligned data"
        )

        for index in 0..<count {
            let padCodeword: UInt8 =
                index.isMultiple(of: 2) ? 0xEC : 0x11

            buffer.append(padCodeword)
        }
    }
}
