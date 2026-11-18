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
    // MARK: - Penalty

    @Test
    func sumsAllRulesOverRowsAndColumns() {
        let matrix = Self.makeMatrix { _, _ in .light }

        let penalty = MaskPenaltyScorer.penalty(for: matrix)

        // 42 runs of 21 modules, 400 blocks, 10 steps of 5%
        #expect(penalty == 42 * 19 + 400 * 3 + 10 * 10)
    }

    @Test
    func scoresFinderLikePatternInRow() {
        let line = Self.colors(Self.finderLikeLine)
        let matrix = Self.makeMatrix { row, column in
            row == 10 ? line[column] : Self.checkerboardColor(row, column)
        }

        let penalty = MaskPenaltyScorer.penalty(for: matrix)

        #expect(penalty == 40)
    }

    @Test
    func scoresFinderLikePatternInColumn() {
        let line = Self.colors(Self.finderLikeLine)
        let matrix = Self.makeMatrix { row, column in
            column == 10 ? line[row] : Self.checkerboardColor(row, column)
        }

        let penalty = MaskPenaltyScorer.penalty(for: matrix)

        #expect(penalty == 40)
    }

    // MARK: - Consecutive Modules

    @Test(arguments: [
        ("11110", 0),
        ("11111", 3),
        ("111111", 4),
        ("0000000", 5)
    ] as [(String, Int)])
    func scoresRunsOfFiveOrMoreModules(
        line: String,
        expectedPenalty: Int
    ) {
        let penalty = MaskPenaltyScorer.consecutiveModulesPenalty(
            in: Self.colors(line)
        )

        #expect(penalty == expectedPenalty)
    }

    @Test
    func scoresEachRunSeparately() {
        let penalty = MaskPenaltyScorer.consecutiveModulesPenalty(
            in: Self.colors("11111000000")
        )

        #expect(penalty == 3 + 4)
    }

    // MARK: - Same-Color Blocks

    @Test
    func scoresSingleBlock() {
        let penalty = MaskPenaltyScorer.sameColorBlocksPenalty(
            in: Self.rows(["110", "110", "001"])
        )

        #expect(penalty == 3)
    }

    @Test(arguments: [
        ["11", "10"],
        ["11", "01"],
        ["10", "11"],
        ["01", "11"]
    ])
    func scoresNothingForBlockWithOneDifferentModule(
        rows: [String]
    ) {
        let penalty = MaskPenaltyScorer.sameColorBlocksPenalty(
            in: Self.rows(rows)
        )

        #expect(penalty == 0)
    }

    @Test
    func scoresOverlappingBlocksSeparately() {
        let penalty = MaskPenaltyScorer.sameColorBlocksPenalty(
            in: Self.rows(["000", "000", "000"])
        )

        #expect(penalty == 4 * 3)
    }

    @Test
    func scoresBlocksInNonSquareGrid() {
        let penalty = MaskPenaltyScorer.sameColorBlocksPenalty(
            in: Self.rows(["1111", "1111"])
        )

        #expect(penalty == 3 * 3)
    }

    // MARK: - Finder-Like Patterns

    @Test(arguments: [
        "00001011101",
        "10111010000",
        "000010111010000",
        "0000110111010000"
    ])
    func scoresPatternWithLightAreaOnce(
        line: String
    ) {
        let penalty = MaskPenaltyScorer.finderLikePatternsPenalty(
            in: Self.colors(line)
        )

        #expect(penalty == 40)
    }

    @Test(arguments: [
        "0001011101000",
        "00000000110011111100110000000000",
        "10111"
    ])
    func scoresNothingWithoutPatternAndLightArea(
        line: String
    ) {
        let penalty = MaskPenaltyScorer.finderLikePatternsPenalty(
            in: Self.colors(line)
        )

        #expect(penalty == 0)
    }

    @Test
    func scoresEachPatternSeparately() {
        let penalty = MaskPenaltyScorer.finderLikePatternsPenalty(
            in: Self.colors("0000101110100001011101")
        )

        #expect(penalty == 2 * 40)
    }

    @Test
    func doesNotTreatModulesPastLineAsLight() {
        let penalty = MaskPenaltyScorer.finderLikePatternsPenalty(
            in: Self.colors("1011101")
        )

        #expect(penalty == 0)
    }

    // MARK: - Dark Module Balance

    @Test(arguments: [
        (0, 100),
        (40, 20),
        (45, 10),
        (46, 0),
        (54, 0),
        (55, 10),
        (60, 20),
        (100, 100)
    ] as [(Int, Int)])
    func scoresEachFullFivePercentDeviationFromHalf(
        darkModuleCount: Int,
        expectedPenalty: Int
    ) {
        let penalty = MaskPenaltyScorer.darkModuleBalancePenalty(
            in: Self.rows(withDarkModuleCount: darkModuleCount)
        )

        #expect(penalty == expectedPenalty)
    }
}

// MARK: - Test Data

private extension MaskPenaltyScorerTests {
    /// A symbol-wide line with one finder-like pattern
    /// and no runs of five or more modules.
    static let finderLikeLine = "010000101110100001010"

    static func colors(
        _ pattern: String
    ) -> [QRModuleColor] {
        pattern.map { character in
            switch character {
            case "0":
                .light

            case "1":
                .dark

            default:
                preconditionFailure(
                    "Test patterns can only contain 0 and 1"
                )
            }
        }
    }

    static func rows(
        _ patterns: [String]
    ) -> [[QRModuleColor]] {
        patterns.map(colors)
    }

    /// A 10×10 grid, so each dark module is 1% of the grid.
    static func rows(
        withDarkModuleCount darkModuleCount: Int
    ) -> [[QRModuleColor]] {
        let size = 10

        return (0..<size).map { row in
            (0..<size).map { column in
                row * size + column < darkModuleCount ? .dark : .light
            }
        }
    }

    static func checkerboardColor(
        _ row: Int,
        _ column: Int
    ) -> QRModuleColor {
        (row + column).isMultiple(of: 2) ? .dark : .light
    }

    static func makeMatrix(
        color: (_ row: Int, _ column: Int) -> QRModuleColor
    ) -> QRMatrix {
        var matrix = QRMatrix(version: .min)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                matrix[row, column] = .data(color: color(row, column))
            }
        }

        return matrix
    }
}
