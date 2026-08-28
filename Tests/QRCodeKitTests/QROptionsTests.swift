//
//  QROptionsTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QROptionsTests {
    
    // MARK: - init(version:encodingMode:errorCorrectionLevel:mask:)
    
    @Test
    func initializesWithDefaultOptions() {
        let options = QROptions()
        
        #expect(options.version == nil)
        #expect(options.encodingMode == nil)
        #expect(options.errorCorrectionLevel == nil)
        #expect(options.mask == nil)
    }
    
    @Test
    func initializesWithPartialOptions() {
        let options = QROptions(
            version: .v5,
            errorCorrectionLevel: .Q
        )
        
        #expect(options.version == .v5)
        #expect(options.encodingMode == nil)
        #expect(options.errorCorrectionLevel == .Q)
        #expect(options.mask == nil)
    }
    
    @Test
    func initializesWithAllOptions() {
        let options = QROptions(
            version: .v10,
            encodingMode: .byte,
            errorCorrectionLevel: .H,
            mask: .pattern6
        )
        
        #expect(options.version == .v10)
        #expect(options.encodingMode == .byte)
        #expect(options.errorCorrectionLevel == .H)
        #expect(options.mask == .pattern6)
    }
}
