//
//  ReedSolomonEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 02.09.2026.
//

/// Generates Reed-Solomon error correction codewords for a single QR data block.
///
/// The input codewords form a message polynomial M(x). For n error correction
/// codewords, the encoder appends n zero coefficients by multiplying M(x) by xⁿ
/// and computes the remainder using polynomial long division over GF(256):
///
/// R(x) = M(x) · xⁿ mod gₙ(x)
///
/// Here, gₙ(x) = (x + α⁰)(x + α¹)...(x + αⁿ⁻¹) is the degree-n generator
/// polynomial and α = 2. Since the degree of R(x) is less than n, its coefficients
/// form the error correction codewords. Leading zeros are restored when necessary
/// so that exactly n codewords are returned.
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
