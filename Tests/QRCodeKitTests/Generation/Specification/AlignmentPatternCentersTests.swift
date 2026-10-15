//
//  AlignmentPatternCentersTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 18.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct AlignmentPatternCentersTests {
    @Test(arguments: QRVersion.allCases)
    func returnCorrectCoordinates(
        version: QRVersion
    ) {
        let coordinates =
            AlignmentPatternCenters.coordinates(
                for: version
            )

        #expect(
            coordinates
                == Self.expectedCoordinates(
                    for: version
                )
        )
    }
}

// MARK: - Test Helpers

private extension AlignmentPatternCentersTests {
    static func expectedCoordinates(
        for version: QRVersion
    ) -> [Int] {
        guard version != .v1 else {
            return []
        }

        let coordinateCount = version.rawValue / 7 + 2
        let intervalCount = coordinateCount - 1

        let firstCoordinate = 6
        let lastCoordinate = version.size - 7
        let distance = lastCoordinate - firstCoordinate

        let averageSpacing =
            Double(distance)
            / Double(intervalCount)

        var step = Int(averageSpacing.rounded())

        if !step.isMultiple(of: 2) {
            step += 1
        }

        var coordinates = Array(
            repeating: 0,
            count: coordinateCount
        )

        coordinates[0] = firstCoordinate

        var position = lastCoordinate

        for index in stride(
            from: coordinateCount - 1,
            through: 1,
            by: -1
        ) {
            coordinates[index] = position
            position -= step
        }

        return coordinates
    }
}
