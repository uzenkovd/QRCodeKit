//
//  BitBuffer.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.08.2026.
//

struct BitBuffer {
    private var bytes: [UInt8]
    private var bitCount: Int
    
    private var byteCount: Int {
        bytes.count
    }
    
    private var lastByte: UInt8? {
        bytes.last
    }
    
    private var isAligned: Bool {
        bitCount.isMultiple(of: 8)
    }
    
    private var usedBits: Int {
        bitCount % 8
    }
    
    private var freeBits: Int {
        (-bitCount) % 8
    }
    
    init() {
        bytes = []
        bitCount = 0
    }
    
    mutating func append(_ value: UInt32, bitCount: Int) {
        precondition(bitCount > 0 && bitCount <= 32)
        
        if bitCount < 32 {
            precondition(value < (1 << bitCount))
            
            var remainingBitCount = bitCount
            
            while remainingBitCount > 0 {
                if isAligned {
                    
                    
                } else {
//                    let lastByte = self.lastByte ?? 0
//                    let bitsToAppend = value >> (bitCount - freeBits)
//                    bytes[byteCount - 1] = lastByte | UInt8(bitsToAppend)
                }
            }
        }
    }
}
