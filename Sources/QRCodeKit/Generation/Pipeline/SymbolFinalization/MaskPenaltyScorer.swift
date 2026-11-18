//
//  MaskPenaltyScorer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 28.09.2026.
//

/// Rates a masked symbol by the penalty rules of the QR code standard.
/// The lower the penalty, the better the mask.
enum MaskPenaltyScorer {
    static func penalty(
        for matrix: QRMatrix
    ) -> Int {
        let rows = moduleColors(of: matrix)
        let columns = rows.indices.map { column in
            rows.map { $0[column] }
        }
        let lines = rows + columns

        let consecutiveModules = lines
            .map(consecutiveModulesPenalty(in:))
            .reduce(0, +)
        let sameColorBlocks = sameColorBlocksPenalty(in: rows)
        let finderLikePatterns = lines
            .map(finderLikePatternsPenalty(in:))
            .reduce(0, +)
        let darkModuleBalance = darkModuleBalancePenalty(in: rows)

        return consecutiveModules
            + sameColorBlocks
            + finderLikePatterns
            + darkModuleBalance
    }
}

// MARK: - Consecutive Modules

extension MaskPenaltyScorer {
    /// Scores 3 points for each run of five modules of the same color,
    /// plus 1 point for each further module in the run.
    static func consecutiveModulesPenalty(
        in line: [QRModuleColor]
    ) -> Int {
        var penalty = 0
        var runColor: QRModuleColor?
        var runLength = 0

        for color in line {
            if color == runColor {
                runLength += 1
            } else {
                runColor = color
                runLength = 1
            }

            if runLength == 5 {
                penalty += 3
            } else if runLength > 5 {
                penalty += 1
            }
        }

        return penalty
    }
}

// MARK: - Same-Color Blocks

extension MaskPenaltyScorer {
    /// Scores 3 points for each 2×2 block of modules of the same color.
    /// Overlapping blocks are scored separately.
    static func sameColorBlocksPenalty(
        in rows: [[QRModuleColor]]
    ) -> Int {
        var penalty = 0

        for row in rows.indices.dropLast() {
            for column in rows[row].indices.dropLast() {
                let topLeft = rows[row][column]
                let topRight = rows[row][column + 1]
                let bottomLeft = rows[row + 1][column]
                let bottomRight = rows[row + 1][column + 1]

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

// MARK: - Finder-Like Patterns

extension MaskPenaltyScorer {
    private static let lightAreaWidth = 4
    private static let finderLikePattern: [QRModuleColor] = [
        .dark, .light, .dark, .dark, .dark, .light, .dark
    ]

    /// Scores 40 points for each `1011101` pattern (1 is dark)
    /// with four light modules before or after it.
    static func finderLikePatternsPenalty(
        in line: [QRModuleColor]
    ) -> Int {
        let pattern = finderLikePattern

        guard line.count >= pattern.count else {
            return 0
        }

        var penalty = 0

        for start in 0...(line.count - pattern.count) {
            let end = start + pattern.count

            guard line[start..<end].elementsEqual(pattern) else {
                continue
            }

            let leadingArea = (start - lightAreaWidth)..<start
            let trailingArea = end..<(end + lightAreaWidth)

            if isLightArea(leadingArea, in: line) ||
                isLightArea(trailingArea, in: line) {
                penalty += 40
            }
        }

        return penalty
    }

    /// Returns whether every module in the area is light.
    /// An area that extends past the line is not light.
    private static func isLightArea(
        _ area: Range<Int>,
        in line: [QRModuleColor]
    ) -> Bool {
        guard area.lowerBound >= 0, area.upperBound <= line.count else {
            return false
        }

        return line[area].allSatisfy { $0 == .light }
    }
}

// MARK: - Dark Module Balance

extension MaskPenaltyScorer {
    /// Scores 10 points for each full 5% by which the proportion
    /// of dark modules deviates from 50%.
    static func darkModuleBalancePenalty(
        in rows: [[QRModuleColor]]
    ) -> Int {
        let modules = rows.joined()
        let totalModuleCount = modules.count
        let darkModuleCount = modules.count(where: { $0 == .dark })

        // |dark / total - 50%| / 5%, in integer arithmetic
        let fivePercentStepCount =
            abs(darkModuleCount * 2 - totalModuleCount) * 10
            / totalModuleCount

        return fivePercentStepCount * 10
    }
}

// MARK: - Module Colors

private extension MaskPenaltyScorer {
    static func moduleColors(
        of matrix: QRMatrix
    ) -> [[QRModuleColor]] {
        (0..<matrix.size).map { row in
            (0..<matrix.size).map { column in
                color(of: matrix[row, column])
            }
        }
    }

    static func color(
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
