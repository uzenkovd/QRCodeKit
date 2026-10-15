//
//  RemainderBits.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 07.09.2026.
//

enum RemainderBits {
    static func bitCount(for version: QRVersion) -> Int {
        guard let entry = table.first(where: {
            $0.versions.contains(version)
        }) else {
            preconditionFailure(
                "Remainder bit count is missing for \(version)"
            )
        }

        return entry.bitCount
    }
}

private extension RemainderBits {
    struct Entry {
        let versions: ClosedRange<QRVersion>
        let bitCount: Int

        init(
            _ versions: ClosedRange<QRVersion>,
            _ bitCount: Int
        ) {
            self.versions = versions
            self.bitCount = bitCount
        }
    }

    static let table = [
        Entry(.v1 ... .v1, 0),
        Entry(.v2 ... .v6, 7),
        Entry(.v7 ... .v13, 0),
        Entry(.v14 ... .v20, 3),
        Entry(.v21 ... .v27, 4),
        Entry(.v28 ... .v34, 3),
        Entry(.v35 ... .v40, 0)
    ]
}
