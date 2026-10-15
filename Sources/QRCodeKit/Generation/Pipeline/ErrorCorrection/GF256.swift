//
//  GF256.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.08.2026.
//

/// An element of GF(2⁸) used by Reed-Solomon arithmetic.
///
/// Every nonzero field value can be represented uniquely as αᵉ, where α = 2
/// is a primitive element and e is in the range 0...254. Thus, value = αᵉ
/// and e = logα(value). Zero has no exponent because logα(0) is undefined.
/// Since the 255 nonzero elements form a cyclic multiplicative group, α²⁵⁵ = 1.
/// Exponent arithmetic during multiplication and division is performed modulo 255.
///
/// The field uses the primitive polynomial
/// p(x) = x⁸ + x⁴ + x³ + x² + 1 (0x11D) for reduction. When multiplication
/// by α = 2 produces a value outside the 8-bit range, reduction modulo p(x)
/// is performed by XORing with 0x11D.
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

    init(exponent: Int) {
        precondition(
            (0..<255).contains(exponent),
            "GF(256) exponent must be in the range 0...254"
        )

        self.value = Self.tables.exponent[exponent]
    }
}

// MARK: - Arithmetic

extension GF256 {
    static func + (lhs: GF256, rhs: GF256) -> GF256 {
        // a + b = a ⊕ b

        GF256(lhs.value ^ rhs.value)
    }

    static func += (lhs: inout GF256, rhs: GF256) {
        lhs = lhs + rhs
    }

    static func - (lhs: GF256, rhs: GF256) -> GF256 {
        // a - b = a + b

        lhs + rhs
    }

    static func -= (lhs: inout GF256, rhs: GF256) {
        lhs = lhs - rhs
    }

    static func * (lhs: GF256, rhs: GF256) -> GF256 {
        // αⁱ · αʲ = α^((i + j) mod 255)

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
        // αⁱ / αʲ = α^((i - j) mod 255)

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
        // exponent[e] = αᵉ and log[αᵉ] = e

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
