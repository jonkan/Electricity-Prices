//
//  CheapestHoursTests.swift
//  Core
//
//  Created by Jonas Värbrand on 2024-11-27.
//

import XCTest
@testable import Core

final class CheapestHoursTests: XCTestCase {

    func testCheapestHour() {
        let prices: [PricePoint] = .mockedPrices
        let cheapestHours = prices.cheapestHours(for: 1)!

        XCTAssertEqual(cheapestHours.price, prices[23].price)
        XCTAssertEqual(cheapestHours.start, prices[23].date)
        XCTAssertEqual(cheapestHours.start, cheapestHours.end.addingTimeInterval(-3600))
        XCTAssertEqual(cheapestHours.duration, 1)
    }

    func testCheapestHours() {
        let prices: [PricePoint] = .mockedPrices
        let cheapestHours = prices.cheapestHours(for: 3)!

        XCTAssertEqual(cheapestHours.price, prices[21...23].map({ $0.price }).reduce(0, +) / 3.0)
        XCTAssertEqual(cheapestHours.start, prices[21].date)
        XCTAssertEqual(cheapestHours.end, prices[23].date.addingTimeInterval(3600))
        XCTAssertEqual(cheapestHours.duration, 3)
    }

    func testDurations() {
        let prices = Array([PricePoint].mockedPrices[0...2])

        for duration in -1...6 {
            let cheapestHours = prices.cheapestHours(for: duration)
            XCTAssertNotNil(cheapestHours)
        }
    }

}
