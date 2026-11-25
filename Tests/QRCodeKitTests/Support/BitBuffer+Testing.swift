//
//  BitBuffer+Testing.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 25.11.2026.
//

@testable import QRCodeKit

extension BitBuffer {
    /// The bits of the buffer as a string of zeros and ones.
    var bitString: String {
        (0..<count).map { self[$0] ? "1" : "0" }.joined()
    }
}

// MARK: - Bytes

extension Collection where Element == UInt8 {
    /// The bits of the bytes as a string of zeros and ones.
    var bitString: String {
        var buffer = BitBuffer()
        buffer.append(contentsOf: self)

        return buffer.bitString
    }
}
