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
            let bitsToAppend = min(freeBits, remainingBits)
            
            if isAligned {
                let newByte: UInt8
                
                if remainingBits < 8 {
                    let extractionShift = bitCount - processedBits - bitsToAppend
                    let shiftedValue = value >> extractionShift
                    
                    let mask: UInt32 = (1 << bitsToAppend) - 1
                    let bits = shiftedValue & mask
                    
                    let placementShift = freeBits - bitsToAppend
                    let shiftedBits = bits << placementShift
                    newByte = UInt8(shiftedBits)
                    
                    storage.append(newByte)
                } else {
                    let extractionShift = bitCount - processedBits - bitsToAppend
                    let shiftedValue = value >> extractionShift
                    
                    let mask: UInt32 = (1 << bitsToAppend) - 1
                    let bits = shiftedValue & mask
                    newByte = UInt8(bits)
                    
                    storage.append(newByte)
                }
            } else {
                guard let lastByte = self.lastByte else {
                    preconditionFailure("BitBuffer is in an invalid state")
                }
                
                let extractionShift = bitCount - processedBits - bitsToAppend
                let shiftedValue = value >> extractionShift
                
                let mask: UInt32 = (1 << bitsToAppend) - 1
                let bits = shiftedValue & mask
                
                let placementShift = freeBits - bitsToAppend
                let shiftedBits = bits << placementShift
                let fullLastByte = lastByte | UInt8(shiftedBits)
                
                storage[byteCount - 1] = fullLastByte
            }
            
            processedBits += bitsToAppend
            remainingBits -= bitsToAppend
            count += bitsToAppend
        }
    }
}

// TODO: Extract bit extraction logic into a helper.
