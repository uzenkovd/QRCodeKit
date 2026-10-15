//
//  BitBuffer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.08.2026.
//

struct BitBuffer {
    private(set) var bytes: [UInt8]
    private(set) var count: Int

    var isAligned: Bool {
        count.isMultiple(of: 8)
    }

    var byteCount: Int {
        bytes.count
    }

    init() {
        bytes = []
        count = 0
    }

    init(minimumCapacity: Int) {
        self.init()
        reserveCapacity(minimumCapacity)
    }

    subscript(index: Int) -> Bool {
        precondition(
            index >= 0 && index < count,
            "Bit index is out of bounds"
        )

        let byteIndex = index / 8
        let bitOffset = index % 8
        let mask = UInt8(0b1000_0000) >> bitOffset

        return (bytes[byteIndex] & mask) != 0
    }

    mutating func reserveCapacity(
        _ minimumCapacity: Int
    ) {
        precondition(
            minimumCapacity >= 0,
            "Minimum capacity must not be negative"
        )

        let fullByteCount = minimumCapacity / 8
        let partialByteCount = minimumCapacity.isMultiple(of: 8) ? 0 : 1
        let minimumByteCapacity = fullByteCount + partialByteCount

        bytes.reserveCapacity(minimumByteCapacity)
    }
}

// MARK: - Appending

extension BitBuffer {
    mutating func append(
        _ value: UInt32,
        bitCount: Int
    ) {
        precondition(
            (0...UInt32.bitWidth).contains(bitCount),
            "Bit count must be in the range 0...32"
        )

        if bitCount < UInt32.bitWidth {
            precondition(
                value < (1 << bitCount),
                "Value does not fit in the specified bit count"
            )
        }

        guard bitCount > 0 else {
            return
        }

        var remainingBitCount = bitCount

        while remainingBitCount > 0 {
            let bitCountToAppend = min(
                freeBitCount,
                remainingBitCount
            )
            let bits = Self.extract(
                from: value,
                remainingBitCount: remainingBitCount,
                bitCountToExtract: bitCountToAppend
            )

            insert(
                bits,
                bitCount: bitCountToAppend
            )

            remainingBitCount -= bitCountToAppend
        }
    }

    mutating func append(
        _ byte: UInt8
    ) {
        if isAligned {
            bytes.append(byte)
        } else {
            bytes[lastByteIndex] |= byte >> usedBitCount
            bytes.append(byte << freeBitCount)
        }

        count += 8
    }

    mutating func append<Bytes: Collection>(
        contentsOf newBytes: Bytes
    ) where Bytes.Element == UInt8 {
        let newByteCount = newBytes.count

        guard newByteCount > 0 else {
            return
        }

        bytes.reserveCapacity(
            byteCount + newByteCount
        )

        if isAligned {
            bytes.append(contentsOf: newBytes)
        } else {
            let currentUsedBitCount = usedBitCount
            let currentFreeBitCount = freeBitCount

            var previousByte = newBytes[newBytes.startIndex]
            bytes[lastByteIndex] |= previousByte >> currentUsedBitCount

            for byte in newBytes.dropFirst() {
                let previousPart = previousByte << currentFreeBitCount
                let currentPart = byte >> currentUsedBitCount
                let combinedByte = previousPart | currentPart

                bytes.append(combinedByte)
                previousByte = byte
            }

            bytes.append(previousByte << currentFreeBitCount)
        }

        count += newByteCount * 8
    }

    mutating func append(
        contentsOf other: BitBuffer
    ) {
        guard other.count > 0 else {
            return
        }

        reserveCapacity(
            count + other.count
        )

        let fullByteCount = other.count / 8
        let trailingBitCount = other.count % 8

        if fullByteCount > 0 {
            append(contentsOf: other.bytes.prefix(fullByteCount))
        }

        guard trailingBitCount > 0 else {
            return
        }

        let trailingByte = other.bytes[fullByteCount]
        let trailingValue = UInt32(trailingByte >> (8 - trailingBitCount))

        append(trailingValue, bitCount: trailingBitCount)
    }
}

// MARK: - Bit Operations

private extension BitBuffer {
    var usedBitCount: Int {
        count % 8
    }

    var freeBitCount: Int {
        8 - usedBitCount
    }

    var lastByteIndex: Int {
        precondition(
            !bytes.isEmpty,
            "Cannot access the last byte of an empty bit buffer"
        )

        return bytes.index(before: bytes.endIndex)
    }

    static func extract(
        from value: UInt32,
        remainingBitCount: Int,
        bitCountToExtract: Int
    ) -> UInt8 {
        let extractionShift = remainingBitCount - bitCountToExtract
        let shiftedValue = value >> extractionShift
        let mask: UInt32 = (1 << bitCountToExtract) - 1

        return UInt8(shiftedValue & mask)
    }

    mutating func insert(
        _ bits: UInt8,
        bitCount: Int
    ) {
        let availableBitCount = freeBitCount

        precondition(
            bitCount > 0 && bitCount <= availableBitCount,
            "Bit count must fit in the available byte space"
        )

        let insertionShift = availableBitCount - bitCount
        let shiftedBits = bits << insertionShift

        if availableBitCount == 8 {
            bytes.append(shiftedBits)
        } else {
            bytes[lastByteIndex] |= shiftedBits
        }

        count += bitCount
    }
}
