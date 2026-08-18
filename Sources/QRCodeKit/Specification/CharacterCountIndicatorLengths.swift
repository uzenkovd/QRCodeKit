//
//  CharacterCountIndicatorLengths.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.08.2026.
//

private struct CharacterCountBitLengths {
    let numeric: Int
    let alphanumeric: Int
    let byte: Int
    let kanji: Int
    
    init(_ numeric: Int, _ alphanumeric: Int, _ byte: Int, _ kanji: Int) {
        self.numeric = numeric
        self.alphanumeric = alphanumeric
        self.byte = byte
        self.kanji = kanji
    }
}

enum CharacterCountIndicatorLengths {
    static func length(
        for version: QRVersion,
        mode: EncodingMode
    ) -> Int {
        guard let lengths = table.first(where: { $0.0.contains(version) })?.1 else {
            preconditionFailure(
                "Character count indicator length is missing for \(version)"
            )
        }
        
        switch mode {
        case .numeric:      return lengths.numeric
        case .alphanumeric: return lengths.alphanumeric
        case .kanji:        return lengths.kanji
        case .byte:         return lengths.byte
        }
    }
}

private extension CharacterCountIndicatorLengths {
    static let table: [(ClosedRange<QRVersion>, CharacterCountBitLengths)] = [
        (.v1 ... .v9, CharacterCountBitLengths(10, 9, 8, 8)),
        (.v10 ... .v26, CharacterCountBitLengths(12, 11, 16, 10)),
        (.v27 ... .v40, CharacterCountBitLengths(14, 13, 16, 12)),
    ]
}
