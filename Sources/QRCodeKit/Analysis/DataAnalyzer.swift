//
//  DataAnalyzer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 12.08.2026.
//

enum DataAnalyzer {
    // MARK: - Encoding Mode

    static func recommendedEncodingMode(
        for message: String
    ) -> EncodingMode? {
        EncodingMode.recommendedOrder.first {
            $0.canEncode(message)
        }
    }

    // MARK: - Capacity

    static func canFit(
        _ characterCount: Int,
        mode: EncodingMode
    ) -> Bool {
        let maxCapacity = CharacterCapacities.maxCapacity(
            for: mode
        )

        return characterCount <= maxCapacity
    }

    static func canFit(
        _ characterCount: Int,
        mode: EncodingMode,
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> Bool {
        let capacity = CharacterCapacities.capacity(
            for: version,
            level: errorCorrectionLevel,
            mode: mode
        )

        return characterCount <= capacity
    }

    // MARK: - Version and Error Correction

    static func minimumVersion(
        for characterCount: Int,
        mode: EncodingMode,
        errorCorrectionLevel: ErrorCorrectionLevel
    ) -> QRVersion? {
        QRVersion.allCases.first {
            canFit(
                characterCount,
                mode: mode,
                version: $0,
                errorCorrectionLevel: errorCorrectionLevel
            )
        }
    }

    static func strongestErrorCorrectionLevel(
        for characterCount: Int,
        mode: EncodingMode,
        version: QRVersion
    ) -> ErrorCorrectionLevel? {
        ErrorCorrectionLevel.descendingOrder.first {
            canFit(
                characterCount,
                mode: mode,
                version: version,
                errorCorrectionLevel: $0
            )
        }
    }
}
