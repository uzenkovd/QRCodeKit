//
//  BitBuffer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.08.2026.
//

struct BitBuffer {
    private var storage: [UInt8]
    private(set) var count: Int
    
    var isAligned: Bool {
        count.isMultiple(of: 8)
    }
    
    var bytes: [UInt8] {
        storage
    }
    
    var byteCount: Int {
        storage.count
    }
    
    private var lastByte: UInt8? {
        storage.last
    }
    
    private var usedBits: Int {
        count % 8
    }
    
    private var freeBits: Int {
        8 - usedBits
    }
    
    init() {
        storage = []
        count = 0
    }
    
    mutating func append(_ value: UInt32, bitCount: Int) {
        precondition(bitCount > 0 && bitCount <= 32)
        
        if bitCount < 32 {
            precondition(value < (1 << bitCount))
        }
        
        var remainingBits = bitCount
        var processedBits = 0
        
        while remainingBits > 0 {
            let newByte: UInt8
            let bitsToAppend = min(freeBits, remainingBits)
            let bits = extractBits(
                from: value,
                bitCount: bitCount,
                processedBits: processedBits,
                bitsToExtract: bitsToAppend
            )
            
            if isAligned {
                if remainingBits < 8 {
                    newByte = insertBits(
                        bits,
                        into: 0,
                        freeBits: freeBits,
                        bitsToInsert: bitsToAppend
                    )
                } else {
                    newByte = UInt8(bits)
                }
                
                storage.append(newByte)
            } else {
                guard let lastByte else {
                    preconditionFailure("BitBuffer is in an invalid state")
                }
                
                newByte = insertBits(
                    bits,
                    into: lastByte,
                    freeBits: freeBits,
                    bitsToInsert: bitsToAppend
                )
                
                storage[byteCount - 1] = newByte
            }
            
            processedBits += bitsToAppend
            remainingBits -= bitsToAppend
            count += bitsToAppend
        }
        
    }
    
    private func extractBits(
        from value: UInt32,
        bitCount: Int,
        processedBits: Int,
        bitsToExtract: Int
    ) -> UInt32 {
        let extractionShift = bitCount - processedBits - bitsToExtract
        let shiftedValue = value >> extractionShift
        
        let mask: UInt32 = (1 << bitsToExtract) - 1
        let bits = shiftedValue & mask
        
        return bits
    }
    
    private func insertBits(
        _ bits: UInt32,
        into byte: UInt8,
        freeBits: Int,
        bitsToInsert: Int
    ) -> UInt8 {
        let insertShift = freeBits - bitsToInsert
        let shiftedBits = bits << insertShift
        let newByte = byte | UInt8(shiftedBits)
        
        return newByte
    }
}
