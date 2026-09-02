//
//  GF256Tests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct GF256Tests {
    // MARK: - Representation

    @Test
    func exponentForZeroIsNil() {
        #expect(GF256.zero.exponent == nil)
    }

    @Test
    func propertiesForKnownValue() {
        let element = GF256(42)

        #expect(element.value == 42)
        #expect(element.exponent == 142)
    }

    @Test
    func equalityUsesValue() {
        #expect(GF256(42) == GF256(42))
        #expect(GF256(42) != GF256(43))
    }

    @Test(arguments: [
        (0x01, 0),
        (0x02, 1),
        (0x80, 7),
        (0x1D, 8),
        (0x3A, 9),
        (0x05, 50),
        (0xCC, 127),
        (0x85, 128),
        (0xFF, 175),
        (0x1C, 200),
        (0x8E, 254)
    ])
    func exponentForKnownValues(value: UInt8, exponent: Int) {
        #expect(GF256(value).exponent == exponent)
    }

    @Test(arguments: [
        (0, 0x01),
        (1, 0x02),
        (7, 0x80),
        (8, 0x1D),
        (9, 0x3A),
        (50, 0x05),
        (127, 0xCC),
        (128, 0x85),
        (175, 0xFF),
        (200, 0x1C),
        (254, 0x8E)
    ])
    func valueForKnownExponents(exponent: Int, value: UInt8) {
        #expect(GF256(exponent: exponent).value == value)
    }

    @Test
    func allNonZeroValuesHaveUniqueExponents() {
        var exponents = Set<Int>()

        for value in UInt8(1) ... .max {
            let exponent = GF256(value).exponent

            #expect(exponent != nil)

            if let exponent {
                exponents.insert(exponent)
            }
        }

        #expect(exponents == Set(0..<255))
    }

    @Test
    func allExponentsRoundTrip() {
        for exponent in 0..<255 {
            let element = GF256(exponent: exponent)

            #expect(element.exponent == exponent)
        }
    }

    // MARK: - Addition

    @Test
    func additionWithZeroReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) + .zero == GF256(value))
            #expect(.zero + GF256(value) == GF256(value))
        }
    }

    @Test
    func additionWithItselfReturnsZero() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) + GF256(value) == .zero)
        }
    }

    @Test(arguments: [
        (0x05, 0x03, 0x06),
        (0x2A, 0x11, 0x3B),
        (0x80, 0x1D, 0x9D),
        (0xFF, 0x8E, 0x71)
    ])
    func additionForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) + GF256(rhs) == GF256(expected))
    }

    @Test
    func additionAssignmentUpdatesValue() {
        var value = GF256(0x2A)

        value += GF256(0x11)

        #expect(value == GF256(0x3B))
    }

    // MARK: - Subtraction

    @Test
    func subtractionWithZeroReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) - .zero == GF256(value))
            #expect(.zero - GF256(value) == GF256(value))
        }
    }

    @Test
    func subtractionFromItselfReturnsZero() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) - GF256(value) == .zero)
        }
    }

    @Test(arguments: [
        (0x05, 0x03, 0x06),
        (0x2A, 0x11, 0x3B),
        (0x80, 0x1D, 0x9D),
        (0xFF, 0x8E, 0x71)
    ])
    func subtractionForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) - GF256(rhs) == GF256(expected))
    }

    @Test
    func subtractionAssignmentUpdatesValue() {
        var value = GF256(0x2A)

        value -= GF256(0x11)

        #expect(value == GF256(0x3B))
    }

    // MARK: - Multiplication

    @Test
    func multiplicationByZeroReturnsZero() {
        for value in UInt8.min ... .max {
            #expect(.zero * GF256(value) == .zero)
            #expect(GF256(value) * .zero == .zero)
        }
    }

    @Test
    func multiplicationByOneReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(.one * GF256(value) == GF256(value))
            #expect(GF256(value) * .one == GF256(value))
        }
    }

    @Test(arguments: [
        (0x05, 0x03, 0x0F),
        (0x2A, 0x11, 0xB0),
        (0xFF, 0x8E, 0xF1),
        (0xCC, 0x85, 0x01),
        (0x1D, 0x3A, 0x98),
        (0x80, 0x80, 0x13)
    ])
    func multiplicationForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) * GF256(rhs) == GF256(expected))
    }

    @Test
    func multiplicationAssignmentUpdatesValue() {
        var value = GF256(0x2A)

        value *= GF256(0x11)

        #expect(value == GF256(0xB0))
    }

    // MARK: - Division

    @Test
    func zeroDividedByNonZeroValueReturnsZero() {
        for value in UInt8(1) ... .max {
            #expect(.zero / GF256(value) == .zero)
        }
    }

    @Test
    func divisionByOneReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) / .one == GF256(value))
        }
    }

    @Test
    func everyNonZeroValueDividedByItselfReturnsOne() {
        for value in UInt8(1) ... .max {
            #expect(GF256(value) / GF256(value) == .one)
        }
    }

    @Test(arguments: [
        (0x05, 0x03, 0x03),
        (0x2A, 0x11, 0xB5),
        (0x8E, 0x02, 0x47),
        (0xFF, 0x8E, 0xE3),
        (0xCC, 0x85, 0x8E)
    ])
    func divisionForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) / GF256(rhs) == GF256(expected))
    }

    @Test
    func divisionAssignmentUpdatesValue() {
        var value = GF256(0x2A)

        value /= GF256(0x11)

        #expect(value == GF256(0xB5))
    }
}
