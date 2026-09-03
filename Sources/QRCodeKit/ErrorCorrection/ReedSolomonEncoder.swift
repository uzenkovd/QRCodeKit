//
//  ReedSolomonEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 02.09.2026.
//

struct ReedSolomonEncoder {
    func encode(
        _ dataCodewords: [UInt8],
        errorCorrectionCodewordCount: Int
    ) -> [UInt8] {
        // R(x) = M(x) · xⁿ mod gₙ(x)

        precondition(
            !dataCodewords.isEmpty,
            "Data codewords must not be empty"
        )
        precondition(
            errorCorrectionCodewordCount > 0,
            "Error correction codeword count must be greater than zero"
        )
        precondition(
            dataCodewords.count + errorCorrectionCodewordCount <= 255,
            "Reed-Solomon block must not exceed 255 codewords"
        )

        let message = Polynomial(dataCodewords)
            .multipliedByXPower(errorCorrectionCodewordCount)
        let generator = Self.generatorPolynomial(
            degree: errorCorrectionCodewordCount
        )
        let remainder = message % generator

        let errorCorrectionCodewords = remainder.coefficients.map(\.value)

        let paddingCount =
            errorCorrectionCodewordCount - errorCorrectionCodewords.count
        let padding = Array(
            repeating: UInt8.zero,
            count: paddingCount
        )

        return padding + errorCorrectionCodewords
    }

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
