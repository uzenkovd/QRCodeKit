//
//  DataEncoderTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.08.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct DataEncoderTests {
    // MARK: - Standard Example

    @Test
    func encodeAnnexIExample() {
        let configuration = QRConfiguration(
            AnnexIExample.version,
            AnnexIExample.errorCorrectionLevel,
            AnnexIExample.encodingMode
        )

        let codewords = DataEncoder.encode(AnnexIExample.message, using: configuration)

        #expect(codewords == AnnexIExample.dataCodewords)
    }

    // MARK: - Segment

    @Test(
        arguments: [
            (.numeric, "1", "0001" + "0000000001" + "0001"),
            (.alphanumeric, "A", "0010" + "000000001" + "001010"),
            (.byte, "a", "0100" + "00000001" + "01100001"),
            (.kanji, "漢", "1000" + "00000001" + "0011100111111"),
        ] as [(QREncodingMode, String, String)]
    )
    func encodeSegmentOfEachMode(
        mode: QREncodingMode,
        message: String,
        expectedSegment: String
    ) {
        let codewords = DataEncoder.encode(message, using: QRConfiguration(.v1, .H, mode))

        #expect(codewords.bitString.hasPrefix(expectedSegment))
    }

    @Test(
        arguments: [
            (.v9, "0100" + "00000001"),
            (.v10, "0100" + "0000000000000001"),
        ] as [(QRVersion, String)]
    )
    func characterCountIndicatorWidensWithVersion(
        version: QRVersion,
        expectedIndicators: String
    ) {
        let codewords = DataEncoder.encode("a", using: QRConfiguration(version, .H, .byte))

        #expect(codewords.bitString.hasPrefix(expectedIndicators))
    }

    @Test
    func characterCountIndicatorCountsBytesInByteMode() {
        let codewords = DataEncoder.encode("\r\n", using: QRConfiguration(.v1, .H, .byte))

        #expect(codewords.bitString.hasPrefix("0100" + "00000010"))
    }

    // MARK: - Terminator and Padding

    @Test
    func appendTerminatorAlignmentAndPadCodewords() {
        let codewords = DataEncoder.encode("1", using: QRConfiguration(.v1, .H, .numeric))

        #expect(codewords.prefix(3).bitString == "0001" + "0000000001" + "0001" + "0000" + "00")
        #expect(codewords.dropFirst(3) == [0xEC, 0x11, 0xEC, 0x11, 0xEC, 0x11])
    }

    @Test
    func shortenTerminatorAtEndOfCapacity() {
        let message = "ABCDEFGHIJKLMNOP"  // 101 of the 104 data bits of 1-Q
        let codewords = DataEncoder.encode(message, using: QRConfiguration(.v1, .Q, .alphanumeric))
        let dataBits = AlphanumericEncoder.encode(message).bitString

        #expect(codewords.bitString == "0010" + "000010000" + dataBits + "000")
    }

    @Test
    func omitTerminatorAtExactCapacity() {
        let message = "1234567890123456789012345678901234"  // all 128 data bits of 1-M
        let codewords = DataEncoder.encode(message, using: QRConfiguration(.v1, .M, .numeric))
        let dataBits = NumericEncoder.encode(message).bitString

        #expect(codewords.bitString == "0001" + "0000100010" + dataBits)
    }
}
