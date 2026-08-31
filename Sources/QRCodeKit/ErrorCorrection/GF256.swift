//
//  GF256.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.08.2026.
//

struct GF256: AdditiveArithmetic {
    static let zero = GF256(0)
    static let one = GF256(1)

    let value: UInt8

    var exponent: Int? {
        Self.tables.log[Int(value)]
    }

    init(_ value: UInt8) {
        self.value = value
    }
}

// MARK: - Arithmetic

extension GF256 {
    static func + (lhs: GF256, rhs: GF256) -> GF256 {
        GF256(lhs.value ^ rhs.value)
    }

    static func += (lhs: inout GF256, rhs: GF256) {
        lhs = lhs + rhs
    }

    static func - (lhs: GF256, rhs: GF256) -> GF256 {
        GF256(lhs.value ^ rhs.value)
    }

    static func -= (lhs: inout GF256, rhs: GF256) {
        lhs = lhs - rhs
    }

    static func * (lhs: GF256, rhs: GF256) -> GF256 {
        guard lhs != .zero, rhs != .zero else {
            return .zero
        }

        let resultExponent = (lhs.exponent! + rhs.exponent!) % 255
        let value = Self.tables.exponent[resultExponent]

        return GF256(value)
    }

    static func *= (lhs: inout GF256, rhs: GF256) {
        lhs = lhs * rhs
    }

    static func / (lhs: GF256, rhs: GF256) -> GF256 {
        precondition(
            rhs != .zero,
            "Division by zero in GF(256)"
        )

        guard lhs != .zero else {
            return .zero
        }

        let resultExponent = (lhs.exponent! - rhs.exponent! + 255) % 255
        let value = Self.tables.exponent[resultExponent]

        return GF256(value)
    }

    static func /= (lhs: inout GF256, rhs: GF256) {
        lhs = lhs / rhs
    }
}

// MARK: - Log and Exponent Tables

private extension GF256 {
    struct Tables {
        let log: [Int?]
        let exponent: [UInt8]

        init(_ log: [Int?], _ exponent: [UInt8]) {
            self.log = log
            self.exponent = exponent
        }
    }

    static let byteLimit = 0x100
    static let modulus = 0x11D

    static let tables = makeTables()

    static func makeTables() -> Tables {
        var logs = Array<Int?>(
            repeating: nil,
            count: 256
        )
        var exponents = Array(
            repeating: UInt8.zero,
            count: 255
        )

        var value = 1

        for exponent in 0..<255 {
            logs[value] = exponent
            exponents[exponent] = UInt8(value)

            value <<= 1

            if value >= byteLimit {
                value ^= modulus
            }
        }

        return Tables(logs, exponents)
    }
}
