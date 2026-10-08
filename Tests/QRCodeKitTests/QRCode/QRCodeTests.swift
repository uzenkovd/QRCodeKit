//
//  QRCodeTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 27.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRCodeTests {
    // MARK: - String Initialization

    @Test
    func rejectsEmptyMessage() {
        #expect(throws: QRCodeError.emptyMessage) {
            try QRCode("")
        }
    }

    @Test
    func rejectsUnsupportedMessage() {
        #expect(throws: QRCodeError.unsupportedMessage) {
            try QRCode("🙂𠜎")
        }
    }

    @Test
    func rejectsMessageAboveMaximumCapacity() {
        let maximumNumericCapacity = 7089
        let message = String(
            repeating: "1",
            count: maximumNumericCapacity + 1
        )

        #expect(throws: QRCodeError.messageIsTooLong) {
            try QRCode(message)
        }
    }

    // MARK: - QRContent Initialization

    @Test
    func initializesFromPlainTextContent() throws {
        let content = QRContent.text("HELLO WORLD")

        let qrCode = try QRCode(content)

        #expect(qrCode.message == content.payload)
    }

    @Test
    func rejectsEmptyPlainTextContent() {
        #expect(throws: QRCodeError.emptyMessage) {
            try QRCode(
                .text("")
            )
        }
    }

    // MARK: - Encoding Mode

    @Test
    func rejectsWrongEncodingMode() {
        let options = QROptions(
            encodingMode: .numeric
        )

        #expect(throws: QRCodeError.wrongEncodingModeForMessage) {
            try QRCode("HELLO", options: options)
        }
    }

    @Test
    func rejectsMessageThatDoesNotFitEncodingMode() {
        let maximumByteCapacity = 2953
        let message = String(
            repeating: "A",
            count: maximumByteCapacity + 1
        )
        let options = QROptions(
            encodingMode: .byte
        )

        #expect(throws: QRCodeError.messageDoesNotFitEncodingMode) {
            try QRCode(
                message,
                options: options
            )
        }
    }

    // MARK: - Version and Error Correction

    @Test
    func rejectsMessageThatDoesNotFitQRConfiguration() {
        let options = QROptions(
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(throws: QRCodeError.messageDoesNotFitQRConfiguration) {
            try QRCode(
                "HELLO WORLD",
                options: options
            )
        }
    }

    @Test
    func rejectsMessageThatDoesNotFitErrorCorrectionLevel() {
        let maximumHNumericCapacity = 3057
        let message = String(
            repeating: "1",
            count: maximumHNumericCapacity + 1
        )
        let options = QROptions(
            errorCorrectionLevel: .H
        )

        #expect(throws: QRCodeError.messageDoesNotFitErrorCorrectionLevel) {
            try QRCode(
                message,
                options: options
            )
        }
    }

    @Test
    func rejectsMessageThatDoesNotFitVersion() {
        let maximumV1LNumericCapacity = 41
        let message = String(
            repeating: "1",
            count: maximumV1LNumericCapacity + 1
        )
        let options = QROptions(
            version: .v1
        )

        #expect(throws: QRCodeError.messageDoesNotFitVersion) {
            try QRCode(
                message,
                options: options
            )
        }
    }

    // MARK: - Explicit Options

    @Test
    func usesSpecifiedOptions() throws {
        let message = "HELLO WORLD"
        let options = QROptions(
            version: .v1,
            encodingMode: .alphanumeric,
            errorCorrectionLevel: .Q,
            mask: .pattern3
        )

        let qrCode = try QRCode(
            message,
            options: options
        )

        #expect(qrCode.message == message)
        #expect(qrCode.version == .v1)
        #expect(qrCode.encodingMode == .alphanumeric)
        #expect(qrCode.errorCorrectionLevel == .Q)
        #expect(qrCode.mask == .pattern3)
        #expect(qrCode.size == 21)
    }

    // MARK: - Automatic Selection

    @Test
    func selectsConfigurationAndMaskAutomatically() throws {
        let qrCode = try QRCode("HELLO WORLD")

        #expect(qrCode.version == .v1)
        #expect(qrCode.encodingMode == .alphanumeric)
        #expect(qrCode.errorCorrectionLevel == .Q)
        #expect(qrCode.mask == .pattern6)
    }

    // MARK: - Reference Symbols

    @Test
    func matchesVersion1QMask0ReferenceSymbol() throws {
        let options = QROptions(
            version: .v1,
            encodingMode: .alphanumeric,
            errorCorrectionLevel: .Q,
            mask: .pattern0
        )

        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )

        let snapshot = Self.binarySnapshot(
            of: qrCode.symbol.matrix
        )

        #expect(snapshot == Self.version1QMask0ReferenceSnapshot)
    }

    @Test
    func matchesVersion7QMask3ReferenceSymbol() throws {
        let options = QROptions(
            version: .v7,
            encodingMode: .alphanumeric,
            errorCorrectionLevel: .Q,
            mask: .pattern3
        )

        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )

        let snapshot = Self.binarySnapshot(
            of: qrCode.symbol.matrix
        )

        #expect(snapshot == Self.version7QMask3ReferenceSnapshot)
    }
}

// MARK: - Reference Symbol Snapshots

private extension QRCodeTests {
    static let version1QMask0ReferenceSnapshot = """
        111111101100001111111
        100000101001001000001
        101110101001101011101
        101110101000001011101
        101110101010001011101
        100000100010001000001
        111111101010101111111
        000000001000000000000
        011010110000101011111
        010000001111000010001
        001101110110001011000
        011011010011010101110
        100010101011101110101
        000000001101001000101
        111111101010000101100
        100000100101101101000
        101110101010001111111
        101110100101010100010
        101110101001011101001
        100000101011110001011
        111111100001011100001
        """

    static let version7QMask3ReferenceSnapshot = """
        111111100001100001110111000001001100101111111
        100000101101010000101101011001010101001000001
        101110101101101010000110001011110001001011101
        101110100010110010101101001010011101101011101
        101110100110010101001111110010100011101011101
        100000100111010100111000110100001100001000001
        111111101010101010101010101010101010101111111
        000000000101001110001000110100111111000000000
        011101100011000110011111111010110000000000110
        011011000111100011011101011001010011000001010
        110000100101111011011000101001001001111111101
        101111000101100000000111110110010011101011100
        110101110010011100000111110101111000101010100
        001010010110111011011001001101000000110011011
        101000101111100101011101100011001110110101010
        111011010000011001100111111001010001011000110
        010100110000010010001011100001101001000000001
        101111000001001010101011101111100101101111101
        011111101100011110110101000100100001100100001
        100110011110111001010100101101011000101000111
        000011111110100100111111100011010110111110000
        010110001111000010111000100000110100100010110
        000010101000110100001010111000001100101011001
        011110001010110001011000101010010011100010100
        101011111111011111101111111011100000111111000
        000010011010000001101010010011001000111110101
        100001101100001001101010010101000111110000101
        000110011111110101101011010000110010110011001
        011010111110011110110010000000001011110101010
        101011001100010101111000110110000100011011100
        101101110000111001101011011101100100111000000
        000110000110101010100001001001001001101000111
        011001101111101101100101111101001111010110010
        101011011000001010010110110110101101010100100
        000010101111011010111100111110010100101100010
        011110010001010100001000110011100100000010011
        100110101010111011111111100010000110111111111
        000000001110011110011000100010111110100010101
        111111100110100101111010110100010010101010101
        100000101010001101111000100100100000100011001
        101110100100111101001111100110010001111111010
        101110101110111011000111000000011011000010010
        101110101010101001011101010011111010111111100
        100000101000000111000111001000101110001111000
        111111100010000111011000110100101000011111010
        """

    // MARK: - Snapshot Formatting

    static func binarySnapshot(
        of matrix: QRMatrix
    ) -> String {
        var rows: [String] = []
        rows.reserveCapacity(matrix.size)

        for row in 0..<matrix.size {
            var snapshotRow = ""
            snapshotRow.reserveCapacity(matrix.size)

            for column in 0..<matrix.size {
                snapshotRow.append(
                    binaryCharacter(
                        for: matrix[row, column]
                    )
                )
            }

            rows.append(snapshotRow)
        }

        return rows.joined(separator: "\n")
    }

    static func binaryCharacter(
        for module: QRModule
    ) -> Character {
        switch module {
        case let .function(_, color),
             let .information(_, color),
             let .data(color):
            return color == .dark ? "1" : "0"

        case .darkModule:
            return "1"

        case .unset, .reserved:
            preconditionFailure(
                "Reference symbol matrix must be finalized"
            )
        }
    }
}
