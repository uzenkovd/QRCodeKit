//
//  ReedSolomonEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 02.09.2026.
//

struct ReedSolomonEncoder {
    static func generatorPolynomial(
        degree: Int
    ) -> Polynomial {
        // gₙ(x) = (x + α⁰)(x + α¹)...(x + αⁿ⁻¹)

        precondition(
            (1...255).contains(degree),
            "Reed-Solomon generator degree must be in the range 1...255"
        )

        var generator = Polynomial.one

        for exponent in 0..<degree {
            let factor = Polynomial([
                .one,
                GF256(exponent: exponent)
            ])

            generator *= factor
        }

        return generator
    }
}
