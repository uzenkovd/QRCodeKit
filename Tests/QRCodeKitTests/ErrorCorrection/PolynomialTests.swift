//
//  PolynomialTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 30.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct PolynomialTests {
    @Test
    func initializationFromUInt8StoresCoefficients() {
        let polynomial = Polynomial([5, 3, 1])

        #expect(polynomial.coefficients == [
            GF256(5),
            GF256(3),
            GF256.one
        ])
    }

    @Test
    func initializationFromGF256StoresCoefficients() {
        let coefficients = [
            GF256(17),
            GF256.zero,
            GF256(255)
        ]

        let polynomial = Polynomial(coefficients)

        #expect(polynomial.coefficients == coefficients)
    }

    @Test(arguments: [
        ([0, 42], [42]),
        ([0, 0, 5, 3, 2], [5, 3, 2]),
        ([0, 0, 0, 255, 1], [255, 1])
    ])
    func leadingZeroCoefficientsAreRemoved(
        coefficients: [UInt8],
        expected: [UInt8]
    ) {
        let polynomial = Polynomial(coefficients)

        #expect(polynomial.coefficients == expected.map(GF256.init))
    }

    @Test(arguments: [
        ([7, 0, 3], [7, 0, 3]),
        ([4, 2, 0], [4, 2, 0]),
        ([0, 0, 6, 0, 1, 0], [6, 0, 1, 0])
    ])
    func nonLeadingZeroCoefficientsArePreserved(
        coefficients: [UInt8],
        expected: [UInt8]
    ) {
        let polynomial = Polynomial(coefficients)

        #expect(polynomial.coefficients == expected.map(GF256.init))
    }

    @Test(arguments: [
        [0],
        [0, 0],
        [0, 0, 0]
    ])
    func allZeroCoefficientsNormalizeToZeroPolynomial(
        coefficients: [UInt8]
    ) {
        let polynomial = Polynomial(coefficients)

        #expect(polynomial.isZero)
        #expect(polynomial.degree == 0)
        #expect(polynomial.coefficients == [.zero])
    }

    @Test(arguments: [
        ([5], 0),
        ([6, 9], 1),
        ([5, 3, 2], 2),
        ([8, 0, 0], 2),
        ([0, 0, 5, 3, 2], 2),
        ([67, 0, 15, 7, 0, 2], 5)
    ])
    func degreeForKnownCoefficients(
        coefficients: [UInt8],
        expected: Int
    ) {
        let polynomial = Polynomial(coefficients)

        #expect(polynomial.degree == expected)
    }

    @Test(arguments: [
        [1],
        [0, 8, 0],
        [2, 0, 0],
        [0, 47, 84, 5]
    ])
    func nonZeroPolynomialsAreNotZero(
        coefficients: [UInt8]
    ) {
        #expect(!Polynomial(coefficients).isZero)
    }
}
