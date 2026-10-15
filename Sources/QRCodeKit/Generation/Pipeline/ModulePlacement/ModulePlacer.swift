//
//  ModulePlacer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 24.09.2026.
//

enum ModulePlacer {
    static func place(
        _ bits: BitBuffer,
        version: QRVersion
    ) -> QRMatrix {
        var matrix = QRMatrix(version: version)

        FinderPattern.place(in: &matrix)
        Separator.place(in: &matrix)
        AlignmentPattern.place(
            in: &matrix,
            version: version
        )
        TimingPattern.place(in: &matrix)
        DarkModule.place(in: &matrix)

        FormatInformationArea.reserve(in: &matrix)
        VersionInformationArea.reserve(
            in: &matrix,
            version: version
        )

        DataPlacer.place(bits, in: &matrix)

        return matrix
    }
}
