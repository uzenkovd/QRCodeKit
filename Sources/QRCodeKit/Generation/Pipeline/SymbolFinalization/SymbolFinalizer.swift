//
//  SymbolFinalizer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.10.2026.
//

/// Turns a matrix with placed data into a symbol: masks the data
/// and places format and version information.
enum SymbolFinalizer {
    /// Builds the symbol with the requested mask or, when none
    /// is requested, with the mask that gives the lowest penalty.
    static func finalize(
        _ matrix: QRMatrix,
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel,
        requestedMask: QRMask?
    ) -> QRSymbol {
        var matrix = matrix

        // Version information does not depend on the mask,
        // so all candidate symbols share it
        VersionInformationArea.place(in: &matrix, version: version)

        if let requestedMask {
            return makeSymbol(
                from: matrix,
                mask: requestedMask,
                errorCorrectionLevel: errorCorrectionLevel
            )
        }

        return makeSymbolWithLowestPenalty(
            from: matrix,
            errorCorrectionLevel: errorCorrectionLevel
        )
    }
}

// MARK: - Symbol Construction

private extension SymbolFinalizer {
    static func makeSymbol(
        from matrix: QRMatrix,
        mask: QRMask,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> QRSymbol {
        var matrix = matrix

        MaskApplier.apply(mask, to: &matrix)
        FormatInformationArea.place(
            in: &matrix,
            errorCorrectionLevel: errorCorrectionLevel,
            mask: mask
        )

        return QRSymbol(matrix: matrix, mask: mask)
    }
}

// MARK: - Mask Selection

private extension SymbolFinalizer {
    /// Tries every mask and keeps the symbol with the lowest penalty.
    /// Ties go to the lower mask number.
    static func makeSymbolWithLowestPenalty(
        from matrix: QRMatrix,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> QRSymbol {
        let candidates = QRMask.allCases.map { mask in
            let symbol = makeSymbol(
                from: matrix,
                mask: mask,
                errorCorrectionLevel: errorCorrectionLevel
            )

            return (
                symbol: symbol,
                penalty: MaskPenaltyScorer.penalty(for: symbol).total
            )
        }

        let best = candidates.min {
            ($0.penalty, $0.symbol.mask.rawValue)
                < ($1.penalty, $1.symbol.mask.rawValue)
        }

        // Never nil: QRMask.allCases is not empty
        return best!.symbol
    }
}
