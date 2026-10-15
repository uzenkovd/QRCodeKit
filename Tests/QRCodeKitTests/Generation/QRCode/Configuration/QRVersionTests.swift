//
//  QRVersionTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 16.09.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRVersionTests {
    @Test
    func calculateSize() {
        #expect(QRVersion.min.size == 21)
        #expect(QRVersion.v10.size == 57)
        #expect(QRVersion.max.size == 177)
    }

    @Test
    func advanceByDistance() {
        #expect(QRVersion.v1.advanced(by: 9) == .v10)
        #expect(QRVersion.v10.advanced(by: -9) == .v1)
    }

    @Test
    func calculateDistance() {
        #expect(QRVersion.v1.distance(to: .v10) == 9)
        #expect(QRVersion.v10.distance(to: .v1) == -9)
    }
}
