//
//  BitBufferTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 17.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct BitBufferTests {
    @Test
    func emptyBitBuffer() {
        let buffer = BitBuffer()

        #expect(buffer.count == 0)
        #expect(buffer.byteCount == 0)
        #expect(buffer.isAligned)
        #expect(buffer.bytes.isEmpty)
    }

    // MARK: - append(_:bitCount:)

    @Test
    func appendOneBit() {
        var buffer = BitBuffer()

        buffer.append(1, bitCount: 1)

        #expect(buffer.count == 1)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10000000])
    }

    @Test
    func appendOneZeroBit() {
        var buffer = BitBuffer()

        buffer.append(0, bitCount: 1)

        #expect(buffer.count == 1)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b00000000])
    }

    @Test
    func appendZeroBits() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(0, bitCount: 0)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10100000])
    }

    @Test
    func appendSixBits() {
        var buffer = BitBuffer()

        buffer.append(0b101101, bitCount: 6)

        #expect(buffer.count == 6)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10110100])
    }

    @Test
    func appendEightBits() {
        var buffer = BitBuffer()

        buffer.append(0b10110110, bitCount: 8)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b10110110])
    }

    @Test
    func appendTenBits() {
        var buffer = BitBuffer()

        buffer.append(0b1011011010, bitCount: 10)

        #expect(buffer.count == 10)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10110110,
            0b10000000
        ])
    }

    @Test
    func appendThirtyTwoBits() {
        var buffer = BitBuffer()

        buffer.append(0xDEADBEEF, bitCount: 32)

        #expect(buffer.count == 32)
        #expect(buffer.byteCount == 4)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    @Test
    func appendExactlyFillsPartialByte() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(0b11001, bitCount: 5)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b10111001])
    }

    @Test
    func appendAcrossByteBoundary() {
        var buffer = BitBuffer()

        buffer.append(0b101101, bitCount: 6)
        buffer.append(0b1101, bitCount: 4)

        #expect(buffer.count == 10)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10110111,
            0b01000000
        ])
    }

    @Test
    func appendAfterAlignedBuffer() {
        var buffer = BitBuffer()

        buffer.append(0b10110110, bitCount: 8)
        buffer.append(0b101, bitCount: 3)

        #expect(buffer.count == 11)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10110110,
            0b10100000
        ])
    }

    @Test
    func appendMultipleValues() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(0b11001, bitCount: 5)
        buffer.append(0b10, bitCount: 2)

        #expect(buffer.count == 10)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10111001,
            0b10000000
        ])
    }

    @Test
    func appendValueWithLeadingZeros() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 8)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b00000101])
    }

    @Test
    func appendValueWithLeadingZerosToPartialByte() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 5)

        #expect(buffer.count == 5)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b00101000])
    }

    @Test
    func appendAllZeros() {
        var buffer = BitBuffer()

        buffer.append(0, bitCount: 8)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b00000000])
    }

    @Test
    func appendMultipleValuesAcrossTwoByteBoundary() {
        var buffer = BitBuffer()

        buffer.append(0b1001, bitCount: 6)
        buffer.append(0b110, bitCount: 6)
        buffer.append(0b1, bitCount: 4)

        #expect(buffer.count == 16)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b00100100,
            0b01100001
        ])
    }

    // MARK: - append(_: UInt8)

    @Test
    func appendByteToEmptyBuffer() {
        var buffer = BitBuffer()
        let byte: UInt8 = 0b10101100

        buffer.append(byte)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b10101100])
    }

    @Test
    func appendByteToUnalignedBuffer() {
        var buffer = BitBuffer()
        let byte: UInt8 = 0b11001010

        buffer.append(0b101, bitCount: 3)
        buffer.append(byte)

        #expect(buffer.count == 11)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10111001,
            0b01000000
        ])
    }

    // MARK: - append(contentsOf: [UInt8])

    @Test
    func appendEmptyBytesToUnalignedBuffer() {
        var buffer = BitBuffer()
        let bytes: [UInt8] = []

        buffer.append(0b101, bitCount: 3)
        buffer.append(contentsOf: bytes)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10100000])
    }

    @Test
    func appendBytesToEmptyBuffer() {
        var buffer = BitBuffer()
        let bytes: [UInt8] = [
            0b10101100,
            0b01010011
        ]

        buffer.append(contentsOf: bytes)

        #expect(buffer.count == 16)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b10101100,
            0b01010011
        ])
    }

    @Test
    func appendBytesToAlignedBuffer() {
        var buffer = BitBuffer()
        let bytes: [UInt8] = [
            0b10101100,
            0b01010011
        ]

        buffer.append(0b11001010, bitCount: 8)
        buffer.append(contentsOf: bytes)

        #expect(buffer.count == 24)
        #expect(buffer.byteCount == 3)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b11001010,
            0b10101100,
            0b01010011
        ])
    }

    @Test
    func appendBytesToUnalignedBuffer() {
        var buffer = BitBuffer()
        let bytes: [UInt8] = [
            0b11001010,
            0b00110101
        ]

        buffer.append(0b101, bitCount: 3)
        buffer.append(contentsOf: bytes)

        #expect(buffer.count == 19)
        #expect(buffer.byteCount == 3)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10111001,
            0b01000110,
            0b10100000
        ])
    }

    // MARK: - append(contentsOf: BitBuffer)

    @Test
    func appendEmptyToEmptyBuffer() {
        var buffer = BitBuffer()
        let other = BitBuffer()

        buffer.append(contentsOf: other)

        #expect(buffer.count == 0)
        #expect(buffer.byteCount == 0)
        #expect(buffer.isAligned)
        #expect(buffer.bytes.isEmpty)
    }

    @Test
    func appendEmptyToAlignedBuffer() {
        var buffer = BitBuffer()
        let other = BitBuffer()

        buffer.append(0b11001100, bitCount: 8)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b11001100])
    }

    @Test
    func appendEmptyToUnalignedBuffer() {
        var buffer = BitBuffer()
        let other = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10100000])
    }

    @Test
    func appendAlignedToEmptyBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        other.append(0b10101010, bitCount: 8)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b10101010])
    }

    @Test
    func appendUnalignedToEmptyBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        other.append(0b101, bitCount: 3)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10100000])
    }

    @Test
    func appendAlignedToAlignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b11001100, bitCount: 8)
        other.append(0b00110011, bitCount: 8)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 16)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b11001100,
            0b00110011
        ])
    }

    @Test
    func appendAlignedToUnalignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        other.append(0b11001100, bitCount: 8)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 11)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b10111001,
            0b10000000
        ])
    }

    @Test
    func appendUnalignedToAlignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b11001100, bitCount: 8)
        other.append(0b101, bitCount: 3)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 11)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b11001100,
            0b10100000
        ])
    }

    @Test
    func appendUnalignedToUnalignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        other.append(0b1101, bitCount: 4)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 7)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b10111010])
    }

    @Test
    func appendMultiByteBufferToUnalignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        other.append(0b1100110010110, bitCount: 13)

        buffer.append(contentsOf: other)

        #expect(buffer.count == 16)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b10111001,
            0b10010110
        ])
    }

    @Test(arguments: Array(1...32))
    func appendBufferWithBitCounts(_ bitCount: Int) {
        var buffer = BitBuffer()
        var other = BitBuffer()

        let value = UInt32.max >> (32 - bitCount)

        other.append(value, bitCount: bitCount)
        buffer.append(contentsOf: other)

        #expect(buffer.count == bitCount)
        #expect(buffer.byteCount == other.byteCount)
        #expect(buffer.isAligned == other.isAligned)
        #expect(buffer.bytes == other.bytes)
    }
}
