//
//  TimingPatternTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 20.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct TimingPatternTests {
    @Test(arguments: QRVersion.allCases)
    func placeTimingPatternsAtCorrectPositions(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let endCoordinate =
            matrix.size - Self.endCoordinateOffset

        let timingRange = Self.startCoordinate...endCoordinate

        TimingPattern.place(in: &matrix)

        for coordinate in timingRange {
            let expectedModule = Self.expectedModule(
                at: coordinate
            )

            #expect(
                matrix[Self.timingCoordinate, coordinate]
                    == expectedModule
            )
            #expect(
                matrix[coordinate, Self.timingCoordinate]
                    == expectedModule
            )
        }
    }

    @Test(arguments: QRVersion.allCases)
    func leaveOtherModulesUnset(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let endCoordinate =
            matrix.size - Self.endCoordinateOffset

        TimingPattern.place(in: &matrix)

        for row in 0..<matrix.size {
            for column in 0..<matrix.size {
                if matrix[row, column] != .unset {
                    #expect(
                        Self.isTimingPatternModule(
                            row: row,
                            column: column,
                            endCoordinate: endCoordinate
                        )
                    )
                }
            }
        }
    }

    @Test(arguments: [
        QRVersion.v7,
        .max
    ])
    func preserveOverlappingAlignmentPatterns(
        version: QRVersion
    ) {
        var matrix = QRMatrix(version: version)

        let coordinates =
            AlignmentPatternCenters.coordinates(
                for: version
            )

        AlignmentPattern.place(
            in: &matrix,
            version: version
        )

        TimingPattern.place(in: &matrix)

        for centerCoordinate in coordinates.dropFirst().dropLast() {
            for offset in -2...2 {
                let coordinate = centerCoordinate + offset
                let expectedModule = QRModule.function(
                    pattern: .alignment,
                    color: Self.expectedColor(
                        at: coordinate
                    )
                )

                #expect(
                    matrix[Self.timingCoordinate, coordinate]
                        == expectedModule
                )
                #expect(
                    matrix[coordinate, Self.timingCoordinate]
                        == expectedModule
                )
            }
        }
    }
}

// MARK: - Test Helpers

private extension TimingPatternTests {
    static let timingCoordinate = 6
    static let startCoordinate = 8
    static let endCoordinateOffset = 9

    static func expectedColor(
        at coordinate: Int
    ) -> QRModuleColor {
        let offset = coordinate - startCoordinate

        return offset.isMultiple(of: 2)
            ? .dark
            : .light
    }

    static func expectedModule(
        at coordinate: Int
    ) -> QRModule {
        let color = expectedColor(at: coordinate)

        return .function(
            pattern: .timing,
            color: color
        )
    }

    static func isTimingPatternModule(
        row: Int,
        column: Int,
        endCoordinate: Int
    ) -> Bool {
        let range = startCoordinate...endCoordinate

        let isHorizontal =
            row == timingCoordinate &&
            range.contains(column)

        let isVertical =
            column == timingCoordinate &&
            range.contains(row)

        return isHorizontal || isVertical
    }
}
