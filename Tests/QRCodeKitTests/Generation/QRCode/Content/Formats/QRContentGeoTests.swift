//
//  QRContentGeoTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRContentGeoTests {
    @Test
    func createsGeolocationContent() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234
        )

        #expect(content.payload == "geo:50.4501,30.5234")
    }

    @Test
    func createsGeolocationContentWithAltitude() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: 180
        )

        #expect(content.payload == "geo:50.4501,30.5234,180")
    }

    @Test
    func createsGeolocationContentWithUncertainty() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            uncertainty: 10
        )

        #expect(content.payload == "geo:50.4501,30.5234;u=10")
    }

    @Test
    func createsGeolocationContentWithAllParameters() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: 180,
            uncertainty: 10
        )

        #expect(content.payload == "geo:50.4501,30.5234,180;u=10")
    }

    @Test
    func preservesZeroAltitude() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: 0
        )

        #expect(content.payload == "geo:50.4501,30.5234,0")
    }

    @Test
    func preservesZeroUncertainty() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            uncertainty: 0
        )

        #expect(content.payload == "geo:50.4501,30.5234;u=0")
    }

    @Test
    func acceptsNegativeAltitude() throws {
        let content = try QRContent.geo(
            latitude: 50.4501,
            longitude: 30.5234,
            altitude: -25.5
        )

        #expect(content.payload == "geo:50.4501,30.5234,-25.5")
    }

    @Test(arguments: [
        -90.0,
        90.0
    ])
    func acceptsLatitudeBoundaryValues(_ latitude: Double) throws {
        let content = try QRContent.geo(
            latitude: latitude,
            longitude: 30
        )

        #expect(content.payload == "geo:\(Int(latitude)),30")
    }

    @Test(arguments: [
        -180.0,
        180.0
    ])
    func acceptsLongitudeBoundaryValues(_ longitude: Double) throws {
        let content = try QRContent.geo(
            latitude: 50,
            longitude: longitude
        )

        #expect(content.payload == "geo:50,\(Int(longitude))")
    }

    @Test
    func formatsSmallGeolocationCoordinates() throws {
        let content = try QRContent.geo(
            latitude: 0.0000001,
            longitude: -0.0000001
        )

        #expect(content.payload == "geo:0.0000001,-0.0000001")
    }

    @Test
    func preservesGeolocationCoordinatePrecision() throws {
        let content = try QRContent.geo(
            latitude: 1.0000000000000002,
            longitude: 30
        )

        #expect(content.payload == "geo:1.0000000000000002,30")
    }

    @Test
    func normalizesNegativeZero() throws {
        let content = try QRContent.geo(
            latitude: -0.0,
            longitude: -0.0,
            altitude: -0.0,
            uncertainty: -0.0
        )

        #expect(content.payload == "geo:0,0,0;u=0")
    }

    @Test(arguments: [
        -90.0001,
        90.0001,
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidLatitudes(_ latitude: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: latitude,
                longitude: 30
            )
        }
    }

    @Test(arguments: [
        -180.0001,
        180.0001,
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidLongitudes(_ longitude: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: 50,
                longitude: longitude
            )
        }
    }

    @Test(arguments: [
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidAltitudes(_ altitude: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: 50,
                longitude: 30,
                altitude: altitude
            )
        }
    }

    @Test(arguments: [
        -0.1,
        -1.0,
        Double.nan,
        Double.infinity,
        -Double.infinity
    ])
    func rejectsInvalidUncertainty(_ uncertainty: Double) {
        #expect(throws: QRContentError.invalidGeolocation) {
            try QRContent.geo(
                latitude: 50,
                longitude: 30,
                uncertainty: uncertainty
            )
        }
    }

    @Test
    func preservesSmallestGeolocationCoordinate() throws {
        let value = Double.leastNonzeroMagnitude

        let content = try QRContent.geo(
            latitude: value,
            longitude: 0
        )

        let coordinate = content.payload
            .dropFirst("geo:".count)
            .split(separator: ",")[0]

        #expect(!coordinate.lowercased().contains("e"))
        #expect(Double(coordinate) == value)
    }
}
