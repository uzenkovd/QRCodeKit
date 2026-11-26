//
//  SymbolFinalizerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 01.10.2026.
//

import Testing

@testable import QRCodeKit

@Suite
struct SymbolFinalizerTests {
    // MARK: - Requested Mask

    /// The penalties of the Annex I example under every mask. They pin
    /// down each candidate symbol and show why mask 2 is selected.
    @Test(
        arguments: [
            (.pattern0, MaskPenalty(155, 102, 80, 0)),
            (.pattern1, MaskPenalty(180, 153, 40, 0)),
            (.pattern2, MaskPenalty(206, 111, 0, 0)),
            (.pattern3, MaskPenalty(187, 105, 40, 0)),
            (.pattern4, MaskPenalty(196, 174, 40, 0)),
            (.pattern5, MaskPenalty(220, 177, 80, 0)),
            (.pattern6, MaskPenalty(191, 108, 80, 0)),
            (.pattern7, MaskPenalty(176, 150, 0, 0)),
        ] as [(QRMask, MaskPenalty)]
    )
    func buildsSymbolWithRequestedMask(
        mask: QRMask,
        expectedPenalty: MaskPenalty
    ) {
        let symbol = SymbolFinalizer.finalize(
            Self.makeMatrix(codewords: AnnexIExample.codewords),
            version: AnnexIExample.version,
            errorCorrectionLevel: AnnexIExample.errorCorrectionLevel,
            requestedMask: mask
        )

        #expect(symbol.mask == mask)
        #expect(MaskPenaltyScorer.penalty(for: symbol) == expectedPenalty)
    }

    // MARK: - Automatic Mask Selection

    @Test
    func selectsMaskWithLowestPenalty() {
        let symbol = SymbolFinalizer.finalize(
            Self.makeMatrix(codewords: AnnexIExample.codewords),
            version: AnnexIExample.version,
            errorCorrectionLevel: AnnexIExample.errorCorrectionLevel,
            requestedMask: nil
        )

        #expect(symbol.mask == AnnexIExample.mask)
        #expect(symbol.moduleColors == AnnexIExample.moduleColors)
    }

    @Test
    func selectsLowerMaskOnTie() {
        let matrix = Self.makeMatrix(codewords: Self.tieCodewords)
        let mask3Penalty = Self.totalPenalty(of: matrix, mask: .pattern3)
        let mask4Penalty = Self.totalPenalty(of: matrix, mask: .pattern4)

        let symbol = SymbolFinalizer.finalize(
            matrix,
            version: .v1,
            errorCorrectionLevel: .M,
            requestedMask: nil
        )

        #expect(mask3Penalty == mask4Penalty)
        #expect(symbol.mask == .pattern3)
    }

    @Test
    func buildsSameSymbolWhetherMaskIsSelectedOrRequested() {
        let codewordCount = ErrorCorrectionBlocks.layout(
            for: .v7,
            level: .L
        ).totalCodewordCount
        let matrix = Self.makeMatrix(
            codewords: Array(repeating: 0, count: codewordCount),
            version: .v7
        )

        let selectedSymbol = SymbolFinalizer.finalize(
            matrix,
            version: .v7,
            errorCorrectionLevel: .L,
            requestedMask: nil
        )
        let requestedSymbol = SymbolFinalizer.finalize(
            matrix,
            version: .v7,
            errorCorrectionLevel: .L,
            requestedMask: selectedSymbol.mask
        )

        #expect(selectedSymbol == requestedSymbol)
    }
}

// MARK: - Test Data

private extension SymbolFinalizerTests {
    /// Version 1 codewords for which, at level M, masks 3 and 4
    /// share the lowest penalty.
    static let tieCodewords = Array(
        repeating: [0x0D, 0x55] as [UInt8],
        count: 13
    ).flatMap { $0 }

    static func makeMatrix(
        codewords: [UInt8],
        version: QRVersion = .v1
    ) -> QRMatrix {
        var bits = BitBuffer(minimumCapacity: codewords.count * 8)
        bits.append(contentsOf: codewords)

        return ModulePlacer.place(bits, version: version)
    }

    static func totalPenalty(
        of matrix: QRMatrix,
        mask: QRMask
    ) -> Int {
        let symbol = SymbolFinalizer.finalize(
            matrix,
            version: .v1,
            errorCorrectionLevel: .M,
            requestedMask: mask
        )

        return MaskPenaltyScorer.penalty(for: symbol).total
    }
}

private extension MaskPenalty {
    /// Takes the rules in order, to keep penalty tables compact.
    init(
        _ consecutiveModules: Int,
        _ sameColorBlocks: Int,
        _ finderLikePatterns: Int,
        _ darkModuleBalance: Int
    ) {
        self.init(
            consecutiveModules: consecutiveModules,
            sameColorBlocks: sameColorBlocks,
            finderLikePatterns: finderLikePatterns,
            darkModuleBalance: darkModuleBalance
        )
    }
}
