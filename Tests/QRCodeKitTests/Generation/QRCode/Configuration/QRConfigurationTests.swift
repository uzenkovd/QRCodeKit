//
//  QRConfigurationTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 24.11.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct QRConfigurationTests {
    // MARK: - characterCountIndicatorBitCount

    @Test(
        arguments: [
            (.v9, .numeric, 10),
            (.v10, .byte, 16),
            (.v40, .alphanumeric, 13),
        ] as [(QRVersion, EncodingMode, Int)]
    )
    func characterCountIndicatorBitCountDependsOnVersionAndMode(
        version: QRVersion,
        mode: EncodingMode,
        expectedBitCount: Int
    ) {
        let configuration = QRConfiguration(version, .M, mode)

        #expect(configuration.characterCountIndicatorBitCount == expectedBitCount)
    }

    // MARK: - dataBitCapacity

    @Test(
        arguments: [
            (.v1, .Q, 13),
            (.v40, .L, 2956),
        ] as [(QRVersion, ErrorCorrectionLevel, Int)]
    )
    func dataBitCapacityCountsBitsOfDataCodewords(
        version: QRVersion,
        level: ErrorCorrectionLevel,
        dataCodewordCount: Int
    ) {
        let configuration = QRConfiguration(version, level, .byte)

        #expect(configuration.dataBitCapacity == dataCodewordCount * 8)
    }

    // MARK: - canFit(characterCount:)

    @Test(arguments: QRVersion.allCases, ErrorCorrectionLevel.allCases)
    func canFitMatchesCharacterCapacityTable(
        version: QRVersion,
        level: ErrorCorrectionLevel
    ) {
        for mode in EncodingMode.allCases {
            let configuration = QRConfiguration(version, level, mode)
            let capacity = CharacterCapacityTable.capacity(for: version, level: level, mode: mode)

            #expect(configuration.canFit(characterCount: capacity))
            #expect(!configuration.canFit(characterCount: capacity + 1))
        }
    }

    @Test(arguments: QRVersion.allCases, ErrorCorrectionLevel.allCases)
    func characterCountIndicatorHoldsCharacterCapacity(
        version: QRVersion,
        level: ErrorCorrectionLevel
    ) {
        for mode in EncodingMode.allCases {
            let configuration = QRConfiguration(version, level, mode)
            let capacity = CharacterCapacityTable.capacity(for: version, level: level, mode: mode)
            let maximumIndicatorValue = (1 << configuration.characterCountIndicatorBitCount) - 1

            #expect(capacity <= maximumIndicatorValue)
        }
    }
}
