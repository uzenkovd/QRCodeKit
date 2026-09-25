//
//  BCHEncoder.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 25.09.2026.
//

/// Generates a systematic Bose-Chaudhuri-Hocquenghem (BCH) codeword
/// using polynomial division over the binary Galois field GF(2).
///
/// The data and generator polynomials are stored as bit-packed integers, where
/// bit i represents the coefficient of xⁱ. For r remainder bits, the encoder
/// multiplies the data polynomial M(x) by xʳ and computes:
///
/// R(x) = M(x) · xʳ mod g(x)
///
/// Since coefficients belong to GF(2), polynomial subtraction is performed
/// using XOR. The returned codeword contains the original data followed by
/// the r-bit remainder:
///
/// C(x) = M(x) · xʳ + R(x)
enum BCHEncoder {
    static func encode(
        _ data: UInt32,
        generator: UInt32,
        remainderBitCount: Int
    ) -> UInt32 {
        precondition(
            remainderBitCount > 0 &&
            remainderBitCount < UInt32.bitWidth,
            "BCH remainder bit count is out of range"
        )
        precondition(
            (generator >> remainderBitCount) == 1,
            "BCH generator degree must match the remainder bit count"
        )
        precondition(
            data < (UInt32(1) << remainderBitCount),
            "BCH data must fit within the remainder bit count"
        )
        precondition(
            data <= (UInt32.max >> remainderBitCount),
            "BCH codeword exceeds UInt32 capacity"
        )

        let leadingBitMask = UInt32(1) << (remainderBitCount - 1)
        var remainder = data

        for _ in 0..<remainderBitCount {
            let hasLeadingBit = (remainder & leadingBitMask) != 0

            remainder <<= 1

            if hasLeadingBit {
                remainder ^= generator
            }
        }

        return (data << remainderBitCount) | remainder
    }
}
