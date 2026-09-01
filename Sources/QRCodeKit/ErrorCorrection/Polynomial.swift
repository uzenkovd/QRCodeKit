//
//  Polynomial.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 30.08.2026.
//

struct Polynomial: AdditiveArithmetic {
    static let zero = Polynomial([GF256.zero])
    static let one = Polynomial([GF256.one])

    let coefficients: [GF256]

    var count: Int {
        coefficients.count
    }

    var degree: Int {
        count - 1
    }

    var isZero: Bool {
        self == .zero
    }

    subscript(index: Int) -> GF256 {
        coefficients[index]
    }

    init(_ coefficients: [UInt8]) {
        self.init(coefficients.map(GF256.init))
    }

    init(_ coefficients: [GF256]) {
        precondition(
            !coefficients.isEmpty,
            "Polynomial requires at least one coefficient"
        )

        let normalizedCoefficients = coefficients.drop {
            $0 == .zero
        }

        self.coefficients = normalizedCoefficients.isEmpty
            ? [.zero]
            : Array(normalizedCoefficients)
    }
}

// MARK: - Arithmetic

extension Polynomial {
    static func + (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        let (longer, shorter) = lhs.count >= rhs.count
            ? (lhs, rhs)
            : (rhs, lhs)

        var resultCoefficients = longer.coefficients
        let offset = longer.count - shorter.count

        for index in 0..<shorter.count {
            resultCoefficients[index + offset] += shorter[index]
        }

        return Polynomial(resultCoefficients)
    }

    static func += (lhs: inout Polynomial, rhs: Polynomial) {
        lhs = lhs + rhs
    }

    static func - (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        // - is identical to + in GF(256): a - b = a + b
        lhs + rhs
    }

    static func -= (lhs: inout Polynomial, rhs: Polynomial) {
        lhs = lhs - rhs
    }

    static func * (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
        var resultCoefficients = Array(
            repeating: GF256.zero,
            count: lhs.count + rhs.count - 1
        )

        for lhsIndex in 0..<lhs.count {
            for rhsIndex in 0..<rhs.count {
                let resultIndex = lhsIndex + rhsIndex
                let product = lhs[lhsIndex] * rhs[rhsIndex]

                resultCoefficients[resultIndex] += product
            }
        }

        return Polynomial(resultCoefficients)
    }

    static func *= (lhs: inout Polynomial, rhs: Polynomial) {
        lhs = lhs * rhs
    }
}
