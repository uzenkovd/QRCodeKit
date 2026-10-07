//
//  DataMaskerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct DataMaskerTests {
    // MARK: - Requested Mask

    @Test(arguments: QRMask.allCases)
    func applyRequestedMaskCorrectly(
        mask: QRMask
    ) {
        let matrix = Self.makeHelloWorldMatrix()

        let expectedMatrix = Self.makeFinalizedMatrix(
            from: matrix,
            version: .v1,
            level: .Q,
            mask: mask
        )

        let symbol = DataMasker.apply(
            to: matrix,
            version: .v1,
            errorCorrectionLevel: .Q,
            requestedMask: mask
        )

        #expect(symbol.mask == mask)
        #expect(symbol.matrix == expectedMatrix)
    }

    // MARK: - Automatic Mask Selection

    @Test(arguments: helloWorldCandidatePenaltyTestCases)
    func scoreHelloWorldMaskCandidateBeforeInformationPlacement(
        mask: QRMask,
        expectedBreakdown: MaskPenaltyScorer.PenaltyBreakdown
    ) {
        var matrix = Self.makeHelloWorldMatrix()

        MaskApplier.apply(
            mask,
            to: &matrix
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown == expectedBreakdown)
    }

    @Test
    func selectLowestPenaltyMaskForHelloWorld() {
        let matrix = Self.makeHelloWorldMatrix()

        let expectedMatrix = Self.makeFinalizedMatrix(
            from: matrix,
            version: .v1,
            level: .Q,
            mask: .pattern6
        )

        let symbol = DataMasker.apply(
            to: matrix,
            version: .v1,
            errorCorrectionLevel: .Q,
            requestedMask: nil
        )

        #expect(symbol.mask == .pattern6)
        #expect(symbol.matrix == expectedMatrix)
    }

    @Test
    func preferFirstMaskWhenMinimumPenaltiesAreEqual() {
        let originalMatrix = Self.makeMaskSelectionTieMatrix()

        let penalties = QRMask.allCases.map { mask in
            var candidateMatrix = originalMatrix

            MaskApplier.apply(
                mask,
                to: &candidateMatrix
            )

            return MaskPenaltyScorer.score(
                for: candidateMatrix
            )
        }

        let expectedPenalties = [
            394, // pattern0
            572, // pattern1
            765, // pattern2
            621, // pattern3
            530, // pattern4
            539, // pattern5
            394, // pattern6
            599  // pattern7
        ]

        #expect(penalties == expectedPenalties)

        let matrix = originalMatrix

        let expectedMatrix = Self.makeFinalizedMatrix(
            from: matrix,
            version: .v1,
            level: .M,
            mask: .pattern0
        )

        let symbol = DataMasker.apply(
            to: matrix,
            version: .v1,
            errorCorrectionLevel: .M,
            requestedMask: nil
        )

        #expect(symbol.mask == .pattern0)
        #expect(symbol.matrix == expectedMatrix)
    }

    // MARK: - Matrix Finalization

    @Test
    func placeVersionInformationForVersion7() {
        let matrix = Self.makeZeroDataMatrix(
            for: .v7,
            level: .L
        )

        let expectedMatrix = Self.makeFinalizedMatrix(
            from: matrix,
            version: .v7,
            level: .L,
            mask: .pattern3
        )

        let symbol = DataMasker.apply(
            to: matrix,
            version: .v7,
            errorCorrectionLevel: .L,
            requestedMask: .pattern3
        )

        #expect(symbol.mask == .pattern3)
        #expect(symbol.matrix == expectedMatrix)
    }
}

// MARK: - "HELLO WORLD" Candidate Test Cases

private extension DataMaskerTests {
    typealias CandidatePenaltyTestCase = (
        mask: QRMask,
        expectedBreakdown: MaskPenaltyScorer.PenaltyBreakdown
    )

    static let helloWorldCandidatePenaltyTestCases: [CandidatePenaltyTestCase] = [
        (
            .pattern0,
            .init(
                consecutiveModules: 200,
                sameColorBlocks: 204,
                finderLikePatterns: 320,
                darkModuleBalance: 10
            )
        ),
        (
            .pattern1,
            .init(
                consecutiveModules: 192,
                sameColorBlocks: 186,
                finderLikePatterns: 120,
                darkModuleBalance: 0
            )
        ),
        (
            .pattern2,
            .init(
                consecutiveModules: 220,
                sameColorBlocks: 198,
                finderLikePatterns: 200,
                darkModuleBalance: 10
            )
        ),
        (
            .pattern3,
            .init(
                consecutiveModules: 189,
                sameColorBlocks: 204,
                finderLikePatterns: 160,
                darkModuleBalance: 0
            )
        ),
        (
            .pattern4,
            .init(
                consecutiveModules: 219,
                sameColorBlocks: 216,
                finderLikePatterns: 320,
                darkModuleBalance: 0
            )
        ),
        (
            .pattern5,
            .init(
                consecutiveModules: 209,
                sameColorBlocks: 195,
                finderLikePatterns: 160,
                darkModuleBalance: 0
            )
        ),
        (
            .pattern6,
            .init(
                consecutiveModules: 196,
                sameColorBlocks: 156,
                finderLikePatterns: 80,
                darkModuleBalance: 0
            )
        ),
        (
            .pattern7,
            .init(
                consecutiveModules: 220,
                sameColorBlocks: 234,
                finderLikePatterns: 360,
                darkModuleBalance: 0
            )
        )
    ]
}

// MARK: - Test Matrices

private extension DataMaskerTests {
    static let helloWorldDataCodewords: [UInt8] = [
        0x20, 0x5B, 0x0B, 0x78, 0xD1, 0x72, 0xDC,
        0x4D, 0x43, 0x40, 0xEC, 0x11, 0xEC
    ]

    static let helloWorldErrorCorrectionCodewords: [UInt8] = [
        0xA8, 0x48, 0x16, 0x52, 0xD9, 0x36, 0x9C,
        0x00, 0x2E, 0x0F, 0xB4, 0x7A, 0x10
    ]

    static func makeHelloWorldMatrix() -> QRMatrix {
        let codewordCount =
            helloWorldDataCodewords.count
            + helloWorldErrorCorrectionCodewords.count

        var bits = BitBuffer(minimumCapacity: codewordCount * 8)

        bits.append(contentsOf: helloWorldDataCodewords)
        bits.append(contentsOf: helloWorldErrorCorrectionCodewords)

        return ModulePlacer.place(
            bits,
            version: .v1
        )
    }

    static func makeMaskSelectionTieMatrix() -> QRMatrix {
        let repetitionCount = 13

        var bits = BitBuffer(
            minimumCapacity: repetitionCount * 2 * 8
        )

        for _ in 0..<repetitionCount {
            bits.append(UInt8(0x00))
            bits.append(UInt8(0x24))
        }

        return ModulePlacer.place(
            bits,
            version: .v1
        )
    }

    static func makeZeroDataMatrix(
        for version: QRVersion,
        level: ErrorCorrectionLevel
    ) -> QRMatrix {
        let codewordCount = ErrorCorrectionBlocks.layout(
            for: version,
            level: level
        ).totalCodewordCount

        let remainderBitCount = RemainderBits.bitCount(
            for: version
        )

        let bitCount = codewordCount * 8 + remainderBitCount
        var bits = BitBuffer(minimumCapacity: bitCount)

        for _ in 0..<codewordCount {
            bits.append(UInt8(0))
        }

        if remainderBitCount > 0 {
            bits.append(
                0,
                bitCount: remainderBitCount
            )
        }

        return ModulePlacer.place(
            bits,
            version: version
        )
    }
}

// MARK: - Matrix Finalization

private extension DataMaskerTests {
    static func makeFinalizedMatrix(
        from matrix: QRMatrix,
        version: QRVersion,
        level: ErrorCorrectionLevel,
        mask: QRMask
    ) -> QRMatrix {
        var finalizedMatrix = matrix

        MaskApplier.apply(
            mask,
            to: &finalizedMatrix
        )

        FormatInformationArea.place(
            in: &finalizedMatrix,
            errorCorrectionLevel: level,
            mask: mask
        )

        VersionInformationArea.place(
            in: &finalizedMatrix,
            version: version
        )

        return finalizedMatrix
    }
}
