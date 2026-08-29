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
    
    // MARK: - init(_:options:) - Message
    
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
        let message = String(repeating: "1", count: 7089 + 1)
        
        #expect(throws: QRCodeError.messageIsTooLong) {
            try QRCode(message)
        }
    }
    
    // MARK: - init(_:options:) - Encoding Mode
    
    @Test
    func rejectsWrongEncodingMode() {
        let options = QROptions(
            encodingMode: .numeric
        )
        
        #expect(throws: QRCodeError.wrongEncodingModeForMessage) {
            try QRCode("HELLO", options: options)
        }
    }
    
    // MARK: - init(_:options:) - Version and Error Correction Level
    
    @Test
    func usesSpecifiedVersionAndErrorCorrectionLevel() throws {
        let options = QROptions(
            version: .v1,
            errorCorrectionLevel: .Q
        )
        
        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )
        
        #expect(qrCode.version == .v1)
        #expect(qrCode.errorCorrectionLevel == .Q)
    }
    
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
    func recommendsMinimumVersionForSpecifiedErrorCorrectionLevel() throws {
        let options = QROptions(
            errorCorrectionLevel: .H
        )
        
        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )
        
        #expect(qrCode.version == .v2)
        #expect(qrCode.errorCorrectionLevel == .H)
    }
    
    @Test
    func rejectsMessageThatDoesNotFitErrorCorrectionLevel() {
        let message = String(repeating: "1", count: 3057 + 1)
        let options = QROptions(
            errorCorrectionLevel: .H
        )
        
        #expect(throws: QRCodeError.messageDoesNotFitErrorCorrectionLevel) {
            try QRCode(message, options: options)
        }
    }
    
    @Test
    func recommendsHighestErrorCorrectionLevelForSpecifiedVersion() throws {
        let options = QROptions(
            version: .v1
        )
        
        let qrCode = try QRCode(
            "HELLO WORLD",
            options: options
        )
        
        #expect(qrCode.version == .v1)
        #expect(qrCode.errorCorrectionLevel == .Q)
    }
    
    @Test
    func rejectsMessageThatDoesNotFitVersion() {
        let message = String(repeating: "1", count: 41 + 1)
        let options = QROptions(
            version: .v1
        )
        
        #expect(throws: QRCodeError.messageDoesNotFitVersion) {
            try QRCode(message, options: options)
        }
    }
    
    // MARK: - init(_:options:) - Automatic Configuration
    
    @Test
    func automaticallyBoostsErrorCorrectionLevelWithoutIncreasingVersion() throws {
        let qrCode = try QRCode("HELLO WORLD")
        
        #expect(qrCode.version == .v1)
        #expect(qrCode.errorCorrectionLevel == .Q)
    }
    
    @Test
    func fallsBackBelowDefaultErrorCorrectionLevelWhenNecessary() throws {
        let message = String(repeating: "1", count: 5596 + 1)
        
        let qrCode = try QRCode(message)
        
        #expect(qrCode.version == .v36)
        #expect(qrCode.errorCorrectionLevel == .L)
    }
}
