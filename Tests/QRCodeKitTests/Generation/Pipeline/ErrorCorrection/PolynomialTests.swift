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
    // MARK: - Representation

    @Test
    func onePolynomialHasExpectedRepresentation() {
        let polynomial = Polynomial.one

        #expect(polynomial.coefficients == [.one])
        #expect(polynomial.count == 1)
        #expect(polynomial.degree == 0)
        #expect(!polynomial.isZero)
    }

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

        #expect(polynomial == .zero)
        #expect(polynomial.coefficients == [.zero])
        #expect(polynomial.count == 1)
        #expect(polynomial.degree == 0)
        #expect(polynomial.isZero)
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

    @Test(arguments: [
        ([5], 1),
        ([6, 7], 2),
        ([2, 3, 0], 3),
        ([0, 9, 5, 0, 2], 4)
    ])
    func countForKnownCoefficients(
        coefficients: [UInt8],
        expected: Int
    ) {
        let polynomial = Polynomial(coefficients)

        #expect(polynomial.count == expected)
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

    @Test
    func subscriptReturnsCoefficientsAtIndex() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial[0] == GF256(5))
        #expect(polynomial[1] == GF256(3))
        #expect(polynomial[2] == GF256(2))
    }

    // MARK: - Addition

    @Test
    func additionWithZeroReturnsSamePolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial + .zero == polynomial)
        #expect(.zero + polynomial == polynomial)
    }

    @Test
    func additionWithItselfReturnsZeroPolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial + polynomial == .zero)
    }

    @Test(arguments: [
        ([5, 3, 2], [7, 4, 1], [2, 7, 3]),  // Equal degrees
        ([5, 3, 2], [7, 4], [5, 4, 6]),     // Lhs has higher degree
        ([7, 4], [5, 3, 2], [5, 4, 6]),     // Rhs has higher degree
        ([5, 3, 2], [5, 7, 4], [4, 6]),     // Leading coefficient cancellation
        ([5, 3, 2], [5, 3, 4], [6])         // Multiple leading coefficient cancellations
    ])
    func additionForKnownPolynomials(
        lhs: [UInt8],
        rhs: [UInt8],
        expected: [UInt8]
    ) {
        #expect(
            Polynomial(lhs) + Polynomial(rhs) == Polynomial(expected)
        )
    }

    @Test
    func additionAssignmentUpdatesPolynomial() {
        var polynomial = Polynomial([5, 3, 2])

        polynomial += Polynomial([7, 4])

        #expect(polynomial == Polynomial([5, 4, 6]))
    }

    // MARK: - Subtraction

    @Test
    func subtractionWithZeroReturnsSamePolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial - .zero == polynomial)
        #expect(.zero - polynomial == polynomial)
    }

    @Test
    func subtractionFromItselfReturnsZeroPolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial - polynomial == .zero)
    }

    @Test(arguments: [
        ([12, 25, 7], [5, 9, 3], [9, 16, 4]),   // Equal degrees
        ([18, 6, 11], [7, 4], [18, 1, 15]),     // Different degrees
        ([21, 8, 3], [21, 13, 7], [5, 4])       // Leading coefficient cancellation
    ])
    func subtractionForKnownPolynomials(
        lhs: [UInt8],
        rhs: [UInt8],
        expected: [UInt8]
    ) {
        #expect(
            Polynomial(lhs) - Polynomial(rhs) == Polynomial(expected)
        )
    }

    @Test
    func subtractionAssignmentUpdatesPolynomial() {
        var polynomial = Polynomial([18, 6, 11])

        polynomial -= Polynomial([7, 4])

        #expect(polynomial == Polynomial([18, 1, 15]))
    }

    // MARK: - Multiplication

    @Test
    func multiplicationByZeroReturnsZeroPolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial * .zero == .zero)
        #expect(.zero * polynomial == .zero)
    }

    @Test
    func multiplicationByOneReturnsSamePolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial * .one == polynomial)
        #expect(.one * polynomial == polynomial)
    }

    @Test(arguments: [
        ([5, 3, 2], [7, 4], [27, 29, 2, 8]),        // Different degrees
        ([7, 4], [5, 3, 2], [27, 29, 2, 8]),        // Reversed operands
        ([5, 3, 2], [7, 4, 1], [27, 29, 7, 11, 2]), // Equal degrees
        ([1, 0, 1], [1, 1], [1, 1, 1, 1]),          // Internal zero coefficient
        ([5], [7, 4, 1], [27, 20, 5]),              // Constant polynomial
        ([1, 0, 0], [7, 4], [7, 4, 0, 0])           // Trailing zero coefficients
    ])
    func multiplicationForKnownPolynomials(
        lhs: [UInt8],
        rhs: [UInt8],
        expected: [UInt8]
    ) {
        #expect(
            Polynomial(lhs) * Polynomial(rhs) == Polynomial(expected)
        )
    }

    @Test
    func multiplicationAssignmentUpdatesPolynomial() {
        var polynomial = Polynomial([5, 3, 2])

        polynomial *= Polynomial([7, 4])

        #expect(polynomial == Polynomial([27, 29, 2, 8]))
    }

    // MARK: - Multiplication by X Power

    @Test
    func zeroMultipliedByXPowerReturnsZero() {
        let zero = Polynomial.zero

        #expect(zero.multipliedByXPower(5) == .zero)
    }

    @Test
    func multiplicationByZeroPowerReturnsPolynomial() {
        let polynomial = Polynomial([5, 3, 2])

        #expect(polynomial.multipliedByXPower(0) == polynomial)
    }

    @Test
    func multiplicationByXPowerAppendsZeroCoefficients() {
        let polynomial = Polynomial([5, 3, 2])

        let result = polynomial.multipliedByXPower(3)

        #expect(result == Polynomial([5, 3, 2, 0, 0, 0]))
    }

    // MARK: - Division

    @Test
    func divisionReturnsQuotient() {
        let dividend = Polynomial([27, 29, 2, 9])
        let divisor = Polynomial([7, 4])

        #expect(dividend / divisor == Polynomial([5, 3, 2]))
    }

    @Test
    func divisionAssignmentUpdatesPolynomial() {
        var polynomial = Polynomial([1, 1, 1, 1])

        polynomial /= Polynomial([1, 1])

        #expect(polynomial == Polynomial([1, 0, 1]))
    }

    // MARK: - Remainder

    @Test
    func remainderReturnsRemainder() {
        let dividend = Polynomial([27, 29, 2, 9])
        let divisor = Polynomial([7, 4])

        #expect(dividend % divisor == .one)
    }

    @Test
    func remainderAssignmentUpdatesPolynomial() {
        var polynomial = Polynomial([1, 1, 1, 1])

        polynomial %= Polynomial([1, 1])

        #expect(polynomial == .zero)
    }

    // MARK: - Long Division

    @Test
    func zeroDividendReturnsZeroQuotientAndRemainder() {
        let dividend = Polynomial.zero

        let division = dividend.quotientAndRemainder(
            dividingBy: Polynomial([7, 4])
        )

        #expect(division.quotient == .zero)
        #expect(division.remainder == .zero)
    }

    @Test
    func divisionByOneReturnsDividendAndZeroRemainder() {
        let dividend = Polynomial([27, 29, 2, 9])

        let division = dividend.quotientAndRemainder(
            dividingBy: .one
        )

        #expect(division.quotient == dividend)
        #expect(division.remainder == .zero)
    }

    @Test
    func divisionByItselfReturnsOneAndZeroRemainder() {
        let polynomial = Polynomial([7, 4, 1])

        let division = polynomial.quotientAndRemainder(
            dividingBy: polynomial
        )

        #expect(division.quotient == .one)
        #expect(division.remainder == .zero)
    }

    @Test
    func lowerDegreeDividendReturnsZeroQuotientAndDividendAsRemainder() {
        let dividend = Polynomial([5, 3])
        let divisor = Polynomial([7, 4, 1])

        let division = dividend.quotientAndRemainder(
            dividingBy: divisor
        )

        #expect(division.quotient == .zero)
        #expect(division.remainder == dividend)
    }

    @Test(arguments: [
        ([27, 29, 2, 8], [7, 4], [5, 3, 2], [0]),   // Exact multi-step division
        ([27, 29, 2, 9], [7, 4], [5, 3, 2], [1]),   // Non-zero remainder
        ([1, 1, 1, 1], [1, 1], [1, 0, 1], [0]),     // Internal zero in quotient
        ([15, 8, 6], [3, 2, 1], [5], [2, 3]),       // Equal degrees, single division step
        ([15, 10, 5], [5], [3, 2, 1], [0]),         // Constant divisor, empty remainder
        ([20, 2, 0, 4], [5, 2, 1], [4, 2], [6]),    // Internal zero in dividend, remainder normalization
        ([6, 12, 7, 2], [3, 0, 1], [2, 4], [5, 6])  // Internal zero in divisor
    ])
    func longDivisionForKnownPolynomials(
        dividend: [UInt8],
        divisor: [UInt8],
        expectedQuotient: [UInt8],
        expectedRemainder: [UInt8]
    ) {
        let dividend = Polynomial(dividend)
        let divisor = Polynomial(divisor)

        let division = dividend.quotientAndRemainder(
            dividingBy: divisor
        )

        #expect(division.quotient == Polynomial(expectedQuotient))
        #expect(division.remainder == Polynomial(expectedRemainder))

        #expect(
            division.remainder.isZero ||
                division.remainder.degree < divisor.degree
        )

        #expect(dividend == divisor * division.quotient + division.remainder)
    }
}
