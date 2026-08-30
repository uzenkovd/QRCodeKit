//
//  Polynomial.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 30.08.2026.
//

struct Polynomial: Equatable {
    let coefficients: [GF256]

    var degree: Int {
        coefficients.count - 1
    }

    var isZero: Bool {
        coefficients.count == 1 && coefficients[0] == .zero
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
