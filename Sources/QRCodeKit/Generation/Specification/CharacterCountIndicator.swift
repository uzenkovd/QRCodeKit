//
//  CharacterCountIndicator.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.08.2026.
//

enum CharacterCountIndicator {
    static func bitCount(
        for version: QRVersion,
        mode: EncodingMode
    ) -> Int {
        guard let bitCounts = table.first(
            where: { $0.versions.contains(version) }
        )?.bitCounts else {
            preconditionFailure(
                "Character count indicator bit count is missing for \(version)"
            )
        }

        switch mode {
        case .numeric:      return bitCounts.numeric
        case .alphanumeric: return bitCounts.alphanumeric
        case .kanji:        return bitCounts.kanji
        case .byte:         return bitCounts.byte
        }
    }
}

private extension CharacterCountIndicator {
    struct BitCounts {
        let numeric: Int
        let alphanumeric: Int
        let byte: Int
        let kanji: Int

        init(
            _ numeric: Int,
            _ alphanumeric: Int,
            _ byte: Int,
            _ kanji: Int
        ) {
            self.numeric = numeric
            self.alphanumeric = alphanumeric
            self.byte = byte
            self.kanji = kanji
        }
    }

    typealias TableEntry = (
        versions: ClosedRange<QRVersion>,
        bitCounts: BitCounts
    )

    static let table: [TableEntry] = [
        (.v1 ... .v9, BitCounts(10, 9, 8, 8)),
        (.v10 ... .v26, BitCounts(12, 11, 16, 10)),
        (.v27 ... .v40, BitCounts(14, 13, 16, 12)),
    ]
}
