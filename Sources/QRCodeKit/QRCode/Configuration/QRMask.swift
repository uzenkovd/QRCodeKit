//
//  QRMask.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum QRMask: Int, Sendable {
    case pattern0 = 0
    case pattern1
    case pattern2
    case pattern3
    case pattern4
    case pattern5
    case pattern6
    case pattern7

    public static let `default`: QRMask = .pattern0

    func shouldInvert(
        atRow row: Int,
        column: Int
    ) -> Bool {
        switch self {
        case .pattern0:
            return (row + column) % 2 == 0

        case .pattern1:
            return row % 2 == 0

        case .pattern2:
            return column % 3 == 0

        case .pattern3:
            return (row + column) % 3 == 0

        case .pattern4:
            return (row / 2 + column / 3) % 2 == 0

        case .pattern5:
            let product = row * column

            return product % 2 + product % 3 == 0

        case .pattern6:
            let product = row * column

            return (product % 2 + product % 3) % 2 == 0

        case .pattern7:
            let sum = row + column
            let product = row * column

            return (sum % 2 + product % 3) % 2 == 0
        }
    }
}
