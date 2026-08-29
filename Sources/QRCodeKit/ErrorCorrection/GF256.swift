//
//  GF256.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 29.08.2026.
//

struct GF256: Equatable {
    let value: UInt8

    var exponent: Int? {
        Self.tables.log[Int(value)]
    }

    init(_ value: UInt8) {
        self.value = value
    }
}

private extension GF256 {
    struct Tables {
        let exponent: [UInt8]
        let log: [Int?]

        init(_ exponent: [UInt8], _ log: [Int?]) {
            self.exponent = exponent
            self.log = log
        }
    }

    static let byteLimit = 0x100
    static let modulus = 0x11D

    static let tables = makeTables()

    static func makeTables() -> Tables {
        var exponents = Array(
            repeating: UInt8.zero,
            count: 255
        )
        var logs = Array<Int?>(
            repeating: nil,
            count: 256
        )

        var value = 1

        for exponent in 0..<255 {
            exponents[exponent] = UInt8(value)
            logs[value] = exponent

            value <<= 1

            if value >= byteLimit {
                value ^= modulus
            }
        }

        return Tables(exponents, logs)
    }
}
