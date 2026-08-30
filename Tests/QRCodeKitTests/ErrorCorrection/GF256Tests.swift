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
    @Test
    func exponentForZeroIsNil() {
        #expect(GF256(0).exponent == nil)
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
        (UInt8(0x01), 0),
        (UInt8(0x02), 1),
        (UInt8(0x80), 7),
        (UInt8(0x1D), 8),
        (UInt8(0x3A), 9),
        (UInt8(0x05), 50),
        (UInt8(0xCC), 127),
        (UInt8(0x85), 128),
        (UInt8(0xFF), 175),
        (UInt8(0x1C), 200),
        (UInt8(0x8E), 254)
    ])
    func exponentForKnownValues(value: UInt8, exponent: Int) {
        #expect(GF256(value).exponent == exponent)
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

    // MARK: - Arithmetic

    @Test
    func additionWithZeroReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) + GF256(0) == GF256(value))
            #expect(GF256(0) + GF256(value) == GF256(value))
        }
    }

    @Test
    func additionWithItselfReturnsZero() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) + GF256(value) == GF256(0))
        }
    }

    @Test(arguments: [
        (UInt8(0x05), UInt8(0x03), UInt8(0x06)),
        (UInt8(0x2A), UInt8(0x11), UInt8(0x3B)),
        (UInt8(0x80), UInt8(0x1D), UInt8(0x9D)),
        (UInt8(0xFF), UInt8(0x8E), UInt8(0x71))
    ])
    func additionForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) + GF256(rhs) == GF256(expected))
    }

    @Test
    func subtractionWithZeroReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) - GF256(0) == GF256(value))
            #expect(GF256(0) - GF256(value) == GF256(value))
        }
    }

    @Test
    func subtractionFromItselfReturnsZero() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) - GF256(value) == GF256(0))
        }
    }

    @Test(arguments: [
        (UInt8(0x05), UInt8(0x03), UInt8(0x06)),
        (UInt8(0x2A), UInt8(0x11), UInt8(0x3B)),
        (UInt8(0x80), UInt8(0x1D), UInt8(0x9D)),
        (UInt8(0xFF), UInt8(0x8E), UInt8(0x71))
    ])
    func subtractionForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) - GF256(rhs) == GF256(expected))
    }

    @Test
    func multiplicationByZeroReturnsZero() {
        for value in UInt8.min ... .max {
            #expect(GF256(0) * GF256(value) == GF256(0))
            #expect(GF256(value) * GF256(0) == GF256(0))
        }
    }

    @Test
    func multiplicationByOneReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(1) * GF256(value) == GF256(value))
            #expect(GF256(value) * GF256(1) == GF256(value))
        }
    }

    @Test(arguments: [
        (UInt8(0x05), UInt8(0x03), UInt8(0x0F)),
        (UInt8(0x2A), UInt8(0x11), UInt8(0xB0)),
        (UInt8(0xFF), UInt8(0x8E), UInt8(0xF1)),
        (UInt8(0xCC), UInt8(0x85), UInt8(0x01)),
        (UInt8(0x1D), UInt8(0x3A), UInt8(0x98)),
        (UInt8(0x80), UInt8(0x80), UInt8(0x13))
    ])
    func multiplicationForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) * GF256(rhs) == GF256(expected))
    }

    @Test
    func zeroDividedByNonZeroValueReturnsZero() {
        for value in UInt8(1) ... .max {
            #expect(GF256(0) / GF256(value) == GF256(0))
        }
    }

    @Test
    func divisionByOneReturnsSameValue() {
        for value in UInt8.min ... .max {
            #expect(GF256(value) / GF256(1) == GF256(value))
        }
    }

    @Test
    func everyNonZeroValueDividedByItselfReturnsOne() {
        for value in UInt8(1) ... .max {
            #expect(GF256(value) / GF256(value) == GF256(1))
        }
    }

    @Test(arguments: [
        (UInt8(0x05), UInt8(0x03), UInt8(0x03)),
        (UInt8(0x2A), UInt8(0x11), UInt8(0xB5)),
        (UInt8(0xFF), UInt8(0x8E), UInt8(0xE3)),
        (UInt8(0xCC), UInt8(0x85), UInt8(0x8E)),
        (UInt8(0x1D), UInt8(0x3A), UInt8(0x8E))
    ])
    func divisionForKnownValues(
        lhs: UInt8,
        rhs: UInt8,
        expected: UInt8
    ) {
        #expect(GF256(lhs) / GF256(rhs) == GF256(expected))
    }
}
