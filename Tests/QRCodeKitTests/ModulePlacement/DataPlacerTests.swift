//
//  DataPlacerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 23.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct DataPlacerTests {
    @Test
    func placeBitsInCorrectOrder() {
        let expectedPositions: [Position] = [
            (20, 20), (20, 19),
            (19, 20), (19, 19),

            (0, 18), (0, 17),
            (1, 18), (1, 17),

            (20, 8), (20, 7),
            (19, 8), (19, 7),

            (0, 5), (0, 4),
            (1, 5), (1, 4)
        ]

        let expectedBits = [
            true, false, false, true,
            false, true, true, false,
            true, true, false, false,
            false, true, false, true
        ]

        var matrix = Self.makeTraversalMatrix(
            withAvailablePositions: expectedPositions
        )
        let bits = Self.makeBitBuffer(
            from: expectedBits
        )

        DataPlacer.place(
            bits,
            in: &matrix
        )

        for (position, bit) in zip(
            expectedPositions,
            expectedBits
        ) {
            let expectedColor: QRModuleColor =
                bit ? .dark : .light

            #expect(
                matrix[position.row, position.column]
                    == .data(color: expectedColor)
            )
        }
    }

    @Test(arguments: QRVersion.allCases)
    func placeBitsInAvailableModules(
        version: QRVersion
    ) {
        var matrix = Self.makePreparedMatrix(
            for: version
        )
        var expectedMatrix = matrix

        for row in 0..<expectedMatrix.size {
            for column in 0..<expectedMatrix.size {
                if expectedMatrix[row, column] == .unset {
                    expectedMatrix[row, column] = .data(
                        color: .light
                    )
                }
            }
        }

        let bitCount = Self.expectedBitCount(
            for: version
        )
        let bits = Self.makeZeroBitBuffer(
            count: bitCount
        )

        DataPlacer.place(
            bits,
            in: &matrix
        )

        #expect(matrix == expectedMatrix)
    }
}

// MARK: - Test Helpers

private extension DataPlacerTests {
    typealias Position = (
        row: Int,
        column: Int
    )

    static func makeTraversalMatrix(
        withAvailablePositions positions: [Position]
    ) -> QRMatrix {
        var matrix = QRMatrix(version: .min)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                matrix[row, column] = .reserved(.format)
            }
        }

        for position in positions {
            matrix[position.row, position.column] = .unset
        }

        return matrix
    }

    static func makePreparedMatrix(
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

        return matrix
    }

    static func makeBitBuffer(
        from bits: [Bool]
    ) -> BitBuffer {
        var buffer = BitBuffer()

        for bit in bits {
            buffer.append(
                bit ? 1 : 0,
                bitCount: 1
            )
        }

        return buffer
    }

    static func makeZeroBitBuffer(
        count: Int
    ) -> BitBuffer {
        var buffer = BitBuffer()

        for _ in 0..<(count / 8) {
            buffer.append(UInt8(0))
        }

        buffer.append(
            0,
            bitCount: count % 8
        )

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
