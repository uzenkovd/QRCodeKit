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

        for value in UInt8(1)...UInt8.max {
            let exponent = GF256(value).exponent

            #expect(exponent != nil)

            if let exponent {
                exponents.insert(exponent)
            }
        }

        #expect(exponents == Set(0..<255))
    }
}
