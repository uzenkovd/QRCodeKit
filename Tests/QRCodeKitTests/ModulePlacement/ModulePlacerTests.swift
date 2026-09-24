//
//  ModulePlacerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 24.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct ModulePlacerTests {
    @Test(arguments: QRVersion.allCases)
    func assembleMatrixCorrectly(
        version: QRVersion
    ) {
        let expectedMatrix = Self.makeExpectedMatrix(
            for: version
        )

        let bitCount = Self.expectedBitCount(
            for: version
        )
        let bits = Self.makeZeroBitBuffer(
            count: bitCount
        )

        let matrix = ModulePlacer.place(
            bits,
            version: version
        )

        #expect(matrix == expectedMatrix)
    }
}

// MARK: - Test Helpers

private extension ModulePlacerTests {
    static func makeExpectedMatrix(
        for version: QRVersion
    ) -> QRMatrix {
        var matrix = QRMatrix(version: version)

        FinderPattern.place(in: &matrix)
        Separator.place(in: &matrix)
        AlignmentPattern.place(
            in: &matrix,
            version: version
        )
        TimingPattern.place(in: &matrix)
        DarkModule.place(in: &matrix)

        FormatInformationArea.reserve(in: &matrix)
        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                if matrix[row, column] == .unset {
                    matrix[row, column] = .data(color: .light)
                }
            }
        }

        return matrix
    }

    static func makeZeroBitBuffer(
        count: Int
    ) -> BitBuffer {
        var buffer = BitBuffer()

        for _ in 0..<(count / 8) {
            buffer.append(UInt8(0))
        }

        let remainingBitCount = count % 8

        if remainingBitCount > 0 {
            buffer.append(
                0,
                bitCount: remainingBitCount
            )
        }

        return buffer
    }

    static func expectedBitCount(
        for version: QRVersion
    ) -> Int {
        let codewordCount = ErrorCorrectionBlocks.layout(
            for: version,
            level: .L
        ).totalCodewordCount

        let remainderBitCount = RemainderBits.bitCount(
            for: version
        )

        return codewordCount * 8 + remainderBitCount
    }
}
