//
//  SymbolFinalizer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.10.2026.
//

enum SymbolFinalizer {
    static func finalize(
        _ matrix: QRMatrix,
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel,
        requestedMask: QRMask?
    ) -> QRSymbol {
        let selectedMask: QRMask
        var symbolMatrix: QRMatrix

        if let requestedMask {
            symbolMatrix = matrix

            MaskApplier.apply(
                requestedMask,
                to: &symbolMatrix
            )

            selectedMask = requestedMask
        } else {
            let bestCandidate = selectBestCandidate(
                for: matrix
            )

            symbolMatrix = bestCandidate.matrix
            selectedMask = bestCandidate.mask
        }

        placeInformation(
            in: &symbolMatrix,
            version: version,
            level: errorCorrectionLevel,
            mask: selectedMask
        )

        return QRSymbol(
            matrix: symbolMatrix,
            mask: selectedMask
        )
    }
}

// MARK: - Automatic Mask Selection

private extension SymbolFinalizer {
    struct Candidate {
        let matrix: QRMatrix
        let mask: QRMask
        let penalty: Int
    }

    static func selectBestCandidate(
        for matrix: QRMatrix
    ) -> Candidate {
        var bestCandidate = makeCandidate(
            from: matrix,
            mask: .pattern0
        )

        for mask in QRMask.allCases.dropFirst() {
            let candidate = makeCandidate(
                from: matrix,
                mask: mask
            )

            if candidate.penalty < bestCandidate.penalty {
                bestCandidate = candidate
            }
        }

        return bestCandidate
    }

    static func makeCandidate(
        from matrix: QRMatrix,
        mask: QRMask
    ) -> Candidate {
        var candidateMatrix = matrix

        MaskApplier.apply(
            mask,
            to: &candidateMatrix
        )

        let penalty = MaskPenaltyScorer.score(
            for: candidateMatrix
        )

        return Candidate(
            matrix: candidateMatrix,
            mask: mask,
            penalty: penalty
        )
    }
}

// MARK: - Information Placement

private extension SymbolFinalizer {
    static func placeInformation(
        in matrix: inout QRMatrix,
        version: QRVersion,
        level: ErrorCorrectionLevel,
        mask: QRMask
    ) {
        FormatInformationArea.place(
            in: &matrix,
            errorCorrectionLevel: level,
            mask: mask
        )

        VersionInformationArea.place(
            in: &matrix,
            version: version
        )
    }
}
