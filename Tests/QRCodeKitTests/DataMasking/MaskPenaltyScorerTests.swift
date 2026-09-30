//
//  MaskPenaltyScorerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct MaskPenaltyScorerTests {
    // MARK: - Consecutive Modules

    @Test
    func returnZeroForAlternatingModules() {
        let matrix = Self.makeCheckerboardMatrix()

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.consecutiveModules == 0)
    }

    @Test
    func scoreConsecutiveModulesInRows() {
        let matrix = Self.makeMatrix(
            withRow: "000011111000000101010"
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.consecutiveModules == 7)
    }

    @Test
    func scoreConsecutiveModulesInColumns() {
        let matrix = Self.makeMatrix(
            withColumn: "000011111000000101010"
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.consecutiveModules == 7)
    }

    // MARK: - Same-Color Blocks

    @Test
    func returnZeroForMixedColorBlocks() {
        let matrix = Self.makeCheckerboardMatrix()

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.sameColorBlocks == 0)
    }

    @Test
    func scoreSingleSameColorBlock() {
        var matrix = Self.makeCheckerboardMatrix()

        Self.fillSquare(
            ofSize: 2,
            with: .dark,
            atRow: 0,
            column: 0,
            in: &matrix
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.sameColorBlocks == 3)
    }

    @Test
    func scoreOverlappingSameColorBlocks() {
        var matrix = Self.makeCheckerboardMatrix()
        let startCoordinate = matrix.size - 3

        Self.fillSquare(
            ofSize: 3,
            with: .light,
            atRow: startCoordinate,
            column: startCoordinate,
            in: &matrix
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.sameColorBlocks == 12)
    }

    // MARK: - Finder-Like Patterns

    @Test(arguments: [
        "000010111010101010101",
        "010101010110111010000"
    ])
    func scoreFinderLikePatternWithRequiredLightModules(
        pattern: String
    ) {
        let matrix = Self.makeMatrix(withRow: pattern)

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.finderLikePatterns == 40)
    }

    @Test
    func scoreFinderLikePatternOnceWithLightModulesOnBothSides() {
        let matrix = Self.makeMatrix(
            withRow: "000010111010000101010"
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.finderLikePatterns == 40)
        #expect(MaskPenaltyScorer.score(for: matrix) == 40)
    }

    @Test
    func ignoreFinderLikeCoreWithoutRequiredLightModules() {
        let matrix = Self.makeMatrix(
            withRow: "010101010111011010101"
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.finderLikePatterns == 0)
    }

    @Test
    func ignoreScaledFinderLikePattern() {
        let matrix = Self.makeMatrix(
            withRow: "0000000011001111110011010",
            version: .v2
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.finderLikePatterns == 0)
    }

    @Test
    func scoreDistinctFinderLikePatternsIndependently() {
        let matrix = Self.makeMatrix(
            withRow: "00001011101000010111010000101",
            version: .v3
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.finderLikePatterns == 80)
    }

    @Test
    func scoreFinderLikePatternInColumns() {
        let matrix = Self.makeMatrix(
            withColumn: "000010111010000101010"
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.finderLikePatterns == 40)
    }

    // MARK: - Dark Module Balance

    @Test(arguments: darkModuleBalanceTestCases)
    func scoreDarkModuleBalance(
        darkModuleCount: Int,
        expectedPenalty: Int
    ) {
        let matrix = Self.makeMatrix(
            withDarkModuleCount: darkModuleCount
        )

        let breakdown = MaskPenaltyScorer.penaltyBreakdown(
            for: matrix
        )

        #expect(breakdown.darkModuleBalance == expectedPenalty)
    }
}

// MARK: - Dark Module Balance Test Cases

private extension MaskPenaltyScorerTests {
    typealias DarkModuleBalanceTestCase = (
        darkModuleCount: Int,
        expectedPenalty: Int
    )

    static let darkModuleBalanceTestCases: [DarkModuleBalanceTestCase] = [
        (0, 100),
        (198, 10),
        (199, 0),
        (221, 0),
        (242, 0),
        (243, 10),
        (441, 100)
    ]
}

// MARK: - Test Matrices

private extension MaskPenaltyScorerTests {
    static func makeCheckerboardMatrix(
        version: QRVersion = .min
    ) -> QRMatrix {
        var matrix = QRMatrix(version: version)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                let sum = row + column
                let color: QRModuleColor =
                    sum.isMultiple(of: 2) ? .dark : .light

                matrix[row, column] = .data(color: color)
            }
        }

        return matrix
    }

    static func makeMatrix(
        withRow pattern: String,
        version: QRVersion = .min
    ) -> QRMatrix {
        var matrix = makeCheckerboardMatrix(
            version: version
        )

        precondition(
            pattern.count == matrix.size,
            "Test row pattern must match the matrix size"
        )

        let row = matrix.size / 2

        for (column, character) in pattern.enumerated() {
            matrix[row, column] = .data(
                color: color(for: character)
            )
        }

        return matrix
    }

    static func makeMatrix(
        withColumn pattern: String,
        version: QRVersion = .min
    ) -> QRMatrix {
        var matrix = makeCheckerboardMatrix(
            version: version
        )

        precondition(
            pattern.count == matrix.size,
            "Test column pattern must match the matrix size"
        )

        let column = matrix.size / 2

        for (row, character) in pattern.enumerated() {
            matrix[row, column] = .data(
                color: color(for: character)
            )
        }

        return matrix
    }

    static func makeMatrix(
        withDarkModuleCount darkModuleCount: Int,
        version: QRVersion = .min
    ) -> QRMatrix {
        var matrix = QRMatrix(version: version)

        let size = matrix.size
        let totalModuleCount = size * size

        precondition(
            (0...totalModuleCount).contains(darkModuleCount),
            "Test dark module count must be within the matrix capacity"
        )

        for row in 0..<size {
            for column in 0..<size {
                let moduleIndex = row * size + column
                let color: QRModuleColor =
                    moduleIndex < darkModuleCount ? .dark : .light

                matrix[row, column] = .data(color: color)
            }
        }

        return matrix
    }

    static func fillSquare(
        ofSize size: Int,
        with color: QRModuleColor,
        atRow startRow: Int,
        column startColumn: Int,
        in matrix: inout QRMatrix
    ) {
        for row in startRow..<(startRow + size) {
            for column in startColumn..<(startColumn + size) {
                matrix[row, column] = .data(color: color)
            }
        }
    }

    static func color(
        for character: Character
    ) -> QRModuleColor {
        switch character {
        case "0":
            return .light

        case "1":
            return .dark

        default:
            preconditionFailure(
                "Test patterns can only contain 0 and 1"
            )
        }
    }
}
