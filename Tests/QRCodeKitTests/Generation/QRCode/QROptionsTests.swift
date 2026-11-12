//
//  QROptionsTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.08.2026.
//

import Testing
import QRCodeKit

@Suite
struct QROptionsTests {
    // MARK: - Initialization

    @Test
    func leavesAllOptionsUnsetByDefault() {
        let options = QROptions()

        #expect(options.version == nil)
        #expect(options.encodingMode == nil)
        #expect(options.errorCorrectionLevel == nil)
        #expect(options.mask == nil)
    }

    @Test
    func storesSpecifiedOptions() {
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

    // MARK: - Mutation

    @Test
    func allowsChangingOptionsAfterInitialization() {
        var options = QROptions()

        options.version = .v10
        options.encodingMode = .byte
        options.errorCorrectionLevel = .H
        options.mask = .pattern6

        #expect(options == QROptions(
            version: .v10,
            encodingMode: .byte,
            errorCorrectionLevel: .H,
            mask: .pattern6
        ))
    }

    // MARK: - Equality

    @Test
    func equalsOptionsWithSameValues() {
        let options = QROptions(version: .v2, mask: .pattern3)

        #expect(options == QROptions(version: .v2, mask: .pattern3))
    }

    @Test(arguments: [
        QROptions(version: .v2),
        QROptions(encodingMode: .byte),
        QROptions(errorCorrectionLevel: .H),
        QROptions(mask: .pattern3)
    ])
    func differsFromOptionsWithAnyDifferentValue(
        _ options: QROptions
    ) {
        #expect(options != QROptions())
    }

    // MARK: - Hashing

    @Test
    func hashesEqualOptionsEqually() {
        let options: Set = [
            QROptions(version: .v2, mask: .pattern3),
            QROptions(version: .v2, mask: .pattern3)
        ]

        #expect(options.count == 1)
    }
}
