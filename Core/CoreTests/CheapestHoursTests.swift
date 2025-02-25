//
//  CheapestHoursTests.swift
//  Core
//
//  Created by Jonas Värbrand on 2024-11-27.
//

import Foundation
import Testing
@testable import Core

struct CheapestHoursTests {

    @Test
    func testCheapestHour() {
        let prices: [PricePoint] = .mockedPrices
        let cheapestHours = prices.cheapestHours(for: 1)!

        #expect(cheapestHours.price == prices[23].price)
        #expect(cheapestHours.start == prices[23].date)
        #expect(cheapestHours.start == cheapestHours.end.addingTimeInterval(-3600))
        #expect(cheapestHours.duration == 1)
    }

    @Test
    func testCheapestHours() {
        let prices: [PricePoint] = .mockedPrices
        let cheapestHours = prices.cheapestHours(for: 3)!

        #expect(cheapestHours.price == prices[21...23].map({ $0.price }).reduce(0, +) / 3.0)
        #expect(cheapestHours.start == prices[21].date)
        #expect(cheapestHours.end == prices[23].date.addingTimeInterval(3600))
        #expect(cheapestHours.duration == 3)
    }

    func testDurations() {
        let prices = Array([PricePoint].mockedPrices[0...2])

        for duration in -1...6 {
            let cheapestHours = prices.cheapestHours(for: duration)
            #expect(cheapestHours != nil)
        }
    }

}
