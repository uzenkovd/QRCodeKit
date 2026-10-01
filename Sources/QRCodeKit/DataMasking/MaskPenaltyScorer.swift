//
//  MaskPenaltyScorer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.09.2026.
//

enum MaskPenaltyScorer {
    static func score(
        for matrix: QRMatrix
    ) -> Int {
        penaltyBreakdown(for: matrix).total
    }

    static func penaltyBreakdown(
        for matrix: QRMatrix
    ) -> PenaltyBreakdown {
        let lineEvaluation = evaluateLines(in: matrix)
        let sameColorBlocks = penaltyForSameColorBlocks(
            in: matrix
        )
        let darkModuleBalance = penaltyForDarkModuleBalance(
            darkModuleCount: lineEvaluation.darkModuleCount,
            totalModuleCount: matrix.size * matrix.size
        )

        return PenaltyBreakdown(
            consecutiveModules: lineEvaluation.consecutiveModulesPenalty,
            sameColorBlocks: sameColorBlocks,
            finderLikePatterns: lineEvaluation.finderLikePatternsPenalty,
            darkModuleBalance: darkModuleBalance
        )
    }
}

// MARK: - Penalty Breakdown

extension MaskPenaltyScorer {
    struct PenaltyBreakdown: Equatable {
        let consecutiveModules: Int
        let sameColorBlocks: Int
        let finderLikePatterns: Int
        let darkModuleBalance: Int

        var total: Int {
            consecutiveModules
            + sameColorBlocks
            + finderLikePatterns
            + darkModuleBalance
        }
    }
}

// MARK: - Line Evaluation

private extension MaskPenaltyScorer {
    struct LineEvaluation {
        let consecutiveModulesPenalty: Int
        let finderLikePatternsPenalty: Int
        let darkModuleCount: Int
    }

    static func evaluateLines(
        in matrix: QRMatrix
    ) -> LineEvaluation {
        let size = matrix.size

        var consecutiveModulesPenalty = 0
        var finderLikePatternsPenalty = 0
        var darkModuleCount = 0

        var columnTrackers = Array(
            repeating: LinePenaltyTracker(),
            count: size
        )

        for row in 0..<size {
            var rowTracker = LinePenaltyTracker()

            for column in 0..<size {
                let color = resolvedColor(
                    of: matrix[row, column]
                )

                rowTracker.process(color)
                columnTrackers[column].process(color)

                if color == .dark {
                    darkModuleCount += 1
                }
            }

            consecutiveModulesPenalty += rowTracker.consecutiveModulesPenalty
            finderLikePatternsPenalty += rowTracker.finderLikePatternsPenalty
        }

        for tracker in columnTrackers {
            consecutiveModulesPenalty += tracker.consecutiveModulesPenalty
            finderLikePatternsPenalty += tracker.finderLikePatternsPenalty
        }

        return LineEvaluation(
            consecutiveModulesPenalty: consecutiveModulesPenalty,
            finderLikePatternsPenalty: finderLikePatternsPenalty,
            darkModuleCount: darkModuleCount
        )
    }
}

// MARK: - Line Penalty Tracking

private extension MaskPenaltyScorer {
    struct LinePenaltyTracker {
        private static let patternWindowBitCount = 11
        private static let requiredLightModuleCount = 4

        private static let patternWindowMask: UInt16 = 0b111_1111_1111
        private static let patternWithLeadingLightModules: UInt16 =
            0b0000_1011101
        private static let patternWithTrailingLightModules: UInt16 =
            0b1011101_0000

        private(set) var consecutiveModulesPenalty = 0
        private(set) var finderLikePatternsPenalty = 0

        private var currentColor: QRModuleColor?
        private var runLength = 0

        private var patternWindow: UInt16 = 0
        private var processedModuleCount = 0
        private var lastPenalizedPatternStart: Int?

        mutating func process(
            _ color: QRModuleColor
        ) {
            processConsecutiveModules(color)
            processFinderLikePatterns(color)
        }

        private mutating func processConsecutiveModules(
            _ color: QRModuleColor
        ) {
            if color == currentColor {
                runLength += 1
            } else {
                currentColor = color
                runLength = 1
            }

            if runLength == 5 {
                consecutiveModulesPenalty += 3
            } else if runLength > 5 {
                consecutiveModulesPenalty += 1
            }
        }

        private mutating func processFinderLikePatterns(
            _ color: QRModuleColor
        ) {
            let bit: UInt16 = color == .dark ? 1 : 0

            patternWindow =
                ((patternWindow << 1) | bit) &
                Self.patternWindowMask

            processedModuleCount += 1

            guard processedModuleCount >= Self.patternWindowBitCount else {
                return
            }

            let windowStart =
                processedModuleCount - Self.patternWindowBitCount

            let patternStart: Int

            if patternWindow == Self.patternWithLeadingLightModules {
                patternStart =
                    windowStart + Self.requiredLightModuleCount
            } else if patternWindow == Self.patternWithTrailingLightModules {
                patternStart = windowStart
            } else {
                return
            }

            guard patternStart != lastPenalizedPatternStart else {
                return
            }

            finderLikePatternsPenalty += 40
            lastPenalizedPatternStart = patternStart
        }
    }
}

// MARK: - Same-Color Blocks

private extension MaskPenaltyScorer {
    static func penaltyForSameColorBlocks(
        in matrix: QRMatrix
    ) -> Int {
        let size = matrix.size
        var penalty = 0

        for row in 0..<(size - 1) {
            for column in 0..<(size - 1) {
                let topLeft = resolvedColor(of: matrix[row, column])
                let topRight = resolvedColor(of: matrix[row, column + 1])
                let bottomLeft = resolvedColor(of: matrix[row + 1, column])
                let bottomRight = resolvedColor(of: matrix[row + 1, column + 1])

                if topLeft == topRight &&
                    topLeft == bottomLeft &&
                    topLeft == bottomRight {
                    penalty += 3
                }
            }
        }

        return penalty
    }
}

// MARK: - Dark Module Balance

private extension MaskPenaltyScorer {
    static func penaltyForDarkModuleBalance(
        darkModuleCount: Int,
        totalModuleCount: Int
    ) -> Int {
        let deviationFromHalf = abs(
            darkModuleCount * 2 - totalModuleCount
        )

        let fivePercentStepCount =
            deviationFromHalf * 10 / totalModuleCount

        return fivePercentStepCount * 10
    }
}

// MARK: - Module Color Resolution

private extension MaskPenaltyScorer {
    static func resolvedColor(
        of module: QRModule
    ) -> QRModuleColor {
        guard let color = module.color else {
            preconditionFailure(
                "Mask penalties cannot be scored while the matrix contains unset modules"
            )
        }

        return color
    }
}
