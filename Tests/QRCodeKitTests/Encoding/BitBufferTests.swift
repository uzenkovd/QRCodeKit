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
    // MARK: - Initialization

    @Test
    func initializesEmptyBuffer() {
        let buffer = BitBuffer()

        #expect(buffer.count == 0)
        #expect(buffer.byteCount == 0)
        #expect(buffer.isAligned)
        #expect(buffer.bytes.isEmpty)
    }

    @Test
    func initializesEmptyBufferWithMinimumCapacity() {
        let buffer = BitBuffer(
            minimumCapacity: 13
        )

        #expect(buffer.count == 0)
        #expect(buffer.byteCount == 0)
        #expect(buffer.isAligned)
        #expect(buffer.bytes.isEmpty)
    }

    // MARK: - reserveCapacity(_:)

    @Test
    func reserveCapacityPreservesContents() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.reserveCapacity(64)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b1010_0000])
    }

    // MARK: - subscript(_:)

    @Test
    func subscriptReturnsBitsInOrder() {
        var buffer = BitBuffer()
        let expectedBits = [
            true, false, true, true,
            false, false, true, false,
            true, false, true, false
        ]

        buffer.append(0b1011_0010_1010, bitCount: 12)

        for index in expectedBits.indices {
            #expect(buffer[index] == expectedBits[index])
        }
    }

    // MARK: - append(_:bitCount:)

    @Test(arguments: [
        (1, 1, [0b1000_0000]),
        (0, 1, [0b0000_0000]),
        (0b101, 5, [0b0010_1000]),
        (0b101, 8, [0b0000_0101]),
        (0b10_1101_1010, 10, [0b1011_0110, 0b1000_0000]),
        (0xDEAD_BEEF, 32, [0xDE, 0xAD, 0xBE, 0xEF])
    ])
    func appendValueToEmptyBuffer(
        value: UInt32,
        bitCount: Int,
        expectedBytes: [UInt8]
    ) {
        var buffer = BitBuffer()

        buffer.append(value, bitCount: bitCount)

        #expect(buffer.count == bitCount)
        #expect(buffer.byteCount == expectedBytes.count)
        #expect(buffer.isAligned == bitCount.isMultiple(of: 8))
        #expect(buffer.bytes == expectedBytes)
    }

    @Test
    func appendZeroBitsDoesNothing() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(0, bitCount: 0)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b1010_0000])
    }

    @Test
    func appendExactlyFillsPartialByte() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(0b11001, bitCount: 5)

        #expect(buffer.count == 8)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [0b1011_1001])
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
            0b1011_0111,
            0b0100_0000
        ])
    }

    @Test
    func appendAcrossMultipleByteBoundaries() {
        var buffer = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(0xDEAD_BEEF, bitCount: 32)

        #expect(buffer.count == 35)
        #expect(buffer.byteCount == 5)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0xBB,
            0xD5,
            0xB7,
            0xDD,
            0xE0
        ])
    }

    // MARK: - append(_:) - UInt8

    @Test
    func appendByteToAlignedBuffer() {
        var buffer = BitBuffer()
        let byte: UInt8 = 0b1010_1100

        buffer.append(0b1100_1010, bitCount: 8)
        buffer.append(byte)

        #expect(buffer.count == 16)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b1100_1010,
            0b1010_1100
        ])
    }

    @Test
    func appendByteToUnalignedBuffer() {
        var buffer = BitBuffer()
        let byte: UInt8 = 0b1100_1010

        buffer.append(0b101, bitCount: 3)
        buffer.append(byte)

        #expect(buffer.count == 11)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b1011_1001,
            0b0100_0000
        ])
    }

    // MARK: - append(contentsOf:) - Byte Collection

    @Test
    func appendEmptyByteCollectionDoesNothing() {
        var buffer = BitBuffer()
        let newBytes: [UInt8] = []

        buffer.append(0b101, bitCount: 3)
        buffer.append(contentsOf: newBytes)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b1010_0000])
    }

    @Test
    func appendByteCollectionToAlignedBuffer() {
        var buffer = BitBuffer()
        let sourceBytes: [UInt8] = [
            0b1111_1111,
            0b1010_1100,
            0b0101_0011,
            0b0000_0000
        ]
        let newBytes = sourceBytes[1...2]

        buffer.append(0b1111_0000, bitCount: 8)
        buffer.append(contentsOf: newBytes)

        #expect(buffer.count == 24)
        #expect(buffer.byteCount == 3)
        #expect(buffer.isAligned)
        #expect(buffer.bytes == [
            0b1111_0000,
            0b1010_1100,
            0b0101_0011
        ])
    }

    @Test
    func appendSingleByteCollectionToUnalignedBuffer() {
        var buffer = BitBuffer()
        let newBytes: [UInt8] = [
            0b1100_1010
        ]

        buffer.append(0b101_0101, bitCount: 7)
        buffer.append(contentsOf: newBytes)

        #expect(buffer.count == 15)
        #expect(buffer.byteCount == 2)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b1010_1011,
            0b1001_0100
        ])
    }

    @Test
    func appendMultipleBytesToUnalignedBuffer() {
        var buffer = BitBuffer()
        let newBytes: [UInt8] = [
            0b1100_1010,
            0b0011_0101
        ]

        buffer.append(1, bitCount: 1)
        buffer.append(contentsOf: newBytes)

        #expect(buffer.count == 17)
        #expect(buffer.byteCount == 3)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b1110_0101,
            0b0001_1010,
            0b1000_0000
        ])
    }

    // MARK: - append(contentsOf:) - BitBuffer

    @Test
    func appendEmptyBufferDoesNothing() {
        var buffer = BitBuffer()
        let other = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        buffer.append(contentsOf: other)

        #expect(buffer.count == 3)
        #expect(buffer.byteCount == 1)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [0b1010_0000])
    }

    @Test(arguments: Array(1...32))
    func appendBufferPreservesBitSequence(
        bitCount: Int
    ) {
        var buffer = BitBuffer()
        var other = BitBuffer()

        let value: UInt32 = 0xA5A5_A5A5 >> (UInt32.bitWidth - bitCount)

        other.append(value, bitCount: bitCount)
        buffer.append(contentsOf: other)

        #expect(buffer.count == other.count)
        #expect(buffer.byteCount == other.byteCount)
        #expect(buffer.isAligned == other.isAligned)
        #expect(buffer.bytes == other.bytes)
    }

    @Test
    func appendAlignedBufferToUnalignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b101, bitCount: 3)
        other.append(0b1100_1100_0011_0101, bitCount: 16)

        buffer.append(contentsOf: other)

        #expect(buffer.count == 19)
        #expect(buffer.byteCount == 3)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b1011_1001,
            0b1000_0110,
            0b1010_0000
        ])
    }

    @Test
    func appendMultiByteUnalignedBufferToUnalignedBuffer() {
        var buffer = BitBuffer()
        var other = BitBuffer()

        buffer.append(0b10_1101, bitCount: 6)
        other.append(0b1_1001_1001_0110, bitCount: 13)

        buffer.append(contentsOf: other)

        #expect(buffer.count == 19)
        #expect(buffer.byteCount == 3)
        #expect(buffer.isAligned == false)
        #expect(buffer.bytes == [
            0b1011_0111,
            0b0011_0010,
            0b1100_0000
        ])
    }
}
