//
//  DataEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 15.08.2026.
//

/// The pipeline step that encodes a message into the data codewords
/// of a symbol: one segment with the message, a terminator, and padding
/// up to the data capacity.
enum DataEncoder {
    static func encode(
        _ message: String,
        using configuration: QRConfiguration
    ) -> [UInt8] {
        let capacity = configuration.dataBitCapacity

        var buffer = BitBuffer(minimumCapacity: capacity)

        appendSegment(for: message, using: configuration, to: &buffer)

        precondition(
            buffer.count <= capacity,
            "Message exceeds the data capacity of the configuration"
        )

        appendTerminator(to: &buffer, capacity: capacity)
        appendPadding(to: &buffer, capacity: capacity)

        return buffer.bytes
    }
}

// MARK: - Segment

private extension DataEncoder {
    /// Appends the mode indicator, the character count indicator
    /// and the data bits of the message.
    static func appendSegment(
        for message: String,
        using configuration: QRConfiguration,
        to buffer: inout BitBuffer
    ) {
        let mode = configuration.encodingMode
        let characterCount = mode.encoder.characterCount(for: message)
        let characterCountIndicatorBitCount = configuration.characterCountIndicatorBitCount

        buffer.append(mode.indicator, bitCount: QREncodingMode.indicatorBitCount)
        buffer.append(UInt32(characterCount), bitCount: characterCountIndicatorBitCount)
        buffer.append(contentsOf: mode.encoder.encode(message))
    }
}

// MARK: - Terminator and Padding

private extension DataEncoder {
    /// The number of zero bits in the terminator, which is shortened
    /// when the data capacity has less room left.
    static let terminatorBitCount = 4

    /// The pad codewords, which alternate to fill the remaining data capacity.
    static let padCodewords: [UInt8] = [0xEC, 0x11]

    static func appendTerminator(
        to buffer: inout BitBuffer,
        capacity: Int
    ) {
        let remainingBitCount = capacity - buffer.count
        let bitCount = min(terminatorBitCount, remainingBitCount)

        buffer.append(0, bitCount: bitCount)
    }

    /// Appends zero bits up to the next codeword boundary,
    /// then pad codewords up to the data capacity.
    static func appendPadding(
        to buffer: inout BitBuffer,
        capacity: Int
    ) {
        let alignmentBitCount = (8 - buffer.count % 8) % 8

        buffer.append(0, bitCount: alignmentBitCount)

        let remainingBitCount = capacity - buffer.count
        let padCodewordCount = remainingBitCount / 8

        for index in 0..<padCodewordCount {
            buffer.append(padCodewords[index % padCodewords.count])
        }
    }
}
