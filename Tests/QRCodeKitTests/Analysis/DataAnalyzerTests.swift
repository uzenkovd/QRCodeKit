//
//  DataAnalyzerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 26.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct DataAnalyzerTests {

    // MARK: - Encoding Mode

    @Test(arguments: [
        ("0123456789", EncodingMode.numeric),
        ("HELLO WORLD", EncodingMode.alphanumeric),
        ("日本語", EncodingMode.kanji),
        ("Café", EncodingMode.byte),
    ])
    func recommendsMostEfficientEncodingMode(
        message: String,
        expectedMode: EncodingMode
    ) {
        let mode = DataAnalyzer.recommendedEncodingMode(
            for: message
        )

        #expect(mode == expectedMode)
    }

    @Test
    func returnsNoRecommendedEncodingModeForUnsupportedMessage() {
        let mode = DataAnalyzer.recommendedEncodingMode(
            for: "🙂𠜎"
        )

        #expect(mode == nil)
    }

    @Test
    func returnsNoRecommendedEncodingModeForEmptyMessage() {
        let mode = DataAnalyzer.recommendedEncodingMode(
            for: ""
        )

        #expect(mode == nil)
    }

    // MARK: - Capacity

    @Test(arguments: [
        (EncodingMode.numeric, 7089),
        (EncodingMode.alphanumeric, 4296),
        (EncodingMode.kanji, 1817),
        (EncodingMode.byte, 2953),
    ])
    func canFitAtMaximumCapacity(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let result = DataAnalyzer.canFit(
            characterCount,
            mode: mode
        )

        #expect(result)
    }

    @Test(arguments: [
        (EncodingMode.numeric, 7089 + 1),
        (EncodingMode.alphanumeric, 4296 + 1),
        (EncodingMode.kanji, 1817 + 1),
        (EncodingMode.byte, 2953 + 1),
    ])
    func cannotFitAboveMaximumCapacity(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let result = DataAnalyzer.canFit(
            characterCount,
            mode: mode
        )

        #expect(!result)
    }

    @Test(arguments: [
        (EncodingMode.numeric, 17),
        (EncodingMode.alphanumeric, 10),
        (EncodingMode.kanji, 4),
        (EncodingMode.byte, 7),
    ])
    func canFitAtConfigurationCapacity(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let result = DataAnalyzer.canFit(
            characterCount,
            mode: mode,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(result)
    }

    @Test(arguments: [
        (EncodingMode.numeric, 17 + 1),
        (EncodingMode.alphanumeric, 10 + 1),
        (EncodingMode.kanji, 4 + 1),
        (EncodingMode.byte, 7 + 1),
    ])
    func cannotFitAboveConfigurationCapacity(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let result = DataAnalyzer.canFit(
            characterCount,
            mode: mode,
            version: .v1,
            errorCorrectionLevel: .H
        )

        #expect(!result)
    }

    // MARK: - Version and Error Correction

    @Test(arguments: [
        (EncodingMode.numeric, 17),
        (EncodingMode.alphanumeric, 10),
        (EncodingMode.kanji, 4),
        (EncodingMode.byte, 7),
    ])
    func minimumVersionIsVersion1AtConfigurationCapacity(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let version = DataAnalyzer.minimumVersion(
            for: characterCount,
            mode: mode,
            errorCorrectionLevel: .H
        )

        #expect(version == .v1)
    }

    @Test(arguments: [
        (EncodingMode.numeric, 236),
        (EncodingMode.alphanumeric, 144),
        (EncodingMode.kanji, 61),
        (EncodingMode.byte, 99),
    ])
    func minimumVersionAdvancesWhenPreviousVersionCapacityIsExceeded(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let version = DataAnalyzer.minimumVersion(
            for: characterCount,
            mode: mode,
            errorCorrectionLevel: .H
        )

        #expect(version == .v10)
    }

    @Test(arguments: [
        (EncodingMode.numeric, 7089 + 1),
        (EncodingMode.alphanumeric, 4296 + 1),
        (EncodingMode.kanji, 1817 + 1),
        (EncodingMode.byte, 2953 + 1),
    ])
    func returnsNoMinimumVersionAboveMaximumCapacity(
        mode: EncodingMode,
        characterCount: Int
    ) {
        let version = DataAnalyzer.minimumVersion(
            for: characterCount,
            mode: mode,
            errorCorrectionLevel: .L
        )

        #expect(version == nil)
    }

    @Test(arguments: [
        (7, ErrorCorrectionLevel.H),
        (8, ErrorCorrectionLevel.Q),
        (12, ErrorCorrectionLevel.M),
        (15, ErrorCorrectionLevel.L),
    ])
    func returnsStrongestFittingErrorCorrectionLevel(
        characterCount: Int,
        expectedLevel: ErrorCorrectionLevel
    ) {
        let level = DataAnalyzer.strongestErrorCorrectionLevel(
            for: characterCount,
            mode: .byte,
            version: .v1
        )

        #expect(level == expectedLevel)
    }

    @Test
    func returnsNoErrorCorrectionLevelWhenVersionCannotFitMessage() {
        let level = DataAnalyzer.strongestErrorCorrectionLevel(
            for: 17 + 1,
            mode: .byte,
            version: .v1
        )

        #expect(level == nil)
    }
}
