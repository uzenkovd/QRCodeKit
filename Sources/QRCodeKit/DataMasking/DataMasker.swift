//
//  DataMasker.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.10.2026.
//

enum DataMasker {
    static func apply(
        to matrix: inout QRMatrix,
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel,
        requestedMask: QRMask?
    ) -> QRMask {
        let selectedMask: QRMask

        if let requestedMask {
            MaskApplier.apply(
                requestedMask,
                to: &matrix
            )

            selectedMask = requestedMask
        } else {
            let bestCandidate = selectBestCandidate(
                for: matrix
            )

            matrix = bestCandidate.matrix
            selectedMask = bestCandidate.mask
        }

        finalize(
            &matrix,
            version: version,
            level: errorCorrectionLevel,
            mask: selectedMask
        )

        return selectedMask
    }
}

// MARK: - Automatic Mask Selection

private extension DataMasker {
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

// MARK: - Matrix Finalization

private extension DataMasker {
    static func finalize(
        _ matrix: inout QRMatrix,
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
