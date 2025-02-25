//
//  EntsoeParsingTests.swift
//  CoreTests
//
//  Created by Jonas Bromö on 2022-09-13.
//

import Foundation
import Testing
@testable import Core

struct EntsoeParsingTests {

    let swedishDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "Europe/Stockholm")
        df.locale = Locale(identifier: "sv_SE")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()

    func loadDayAheadPrices(_ filename: String) throws -> EntsoeDayAheadPrices {
        let url = Bundle.module.url(forResource: filename, withExtension: nil)!
        let xmlData = try Data(contentsOf: url)
        return try EntsoePricesAPI.shared.parseDayAheadPrices(fromXML: xmlData)
    }

    @Test
    func testDecodeDayAheadPrices1() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-1.xml")
        #expect(dayAheadPrices.timeSeries.count == 2)
        #expect(dayAheadPrices.periodTimeInterval.start.debugDescription == "2022-08-25 22:00:00 +0000")
        #expect(dayAheadPrices.periodTimeInterval.end.debugDescription == "2022-08-27 22:00:00 +0000")
        #expect(dayAheadPrices.timeSeries[0].period[0].point[3].position == 4)
        #expect(dayAheadPrices.timeSeries[0].period[0].point[3].priceAmount == 8.18)
    }

    @Test
    func testPrices1() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-1.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        let date1 = swedishDateFormatter.date(from: "2022-08-26 08:00:00")!
        #expect(almostEqual(prices.price(for: date1)!.price, 0.61996))
    }

    @Test
    func testPrices2() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-1.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        let date1 = swedishDateFormatter.date(from: "2022-08-26 14:33:00")!
        #expect(almostEqual(prices.price(for: date1)!.price, 0.62810))
    }

    @Test
    func testPricesOrderedChronologically() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-1.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        #expect(prices.first!.date < prices.last!.date)
    }

    @Test
    func testMultiplePeriods() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-4.xml")
        let lastDate = try dayAheadPrices.prices(using: .mockedSEK).last!.date
        let day = Calendar.current.component(.day, from: lastDate)
        #expect(day == 6)
    }

    @Test
    func testA03CurveType() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-5.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        #expect(prices.count == 24)
        #expect(almostEqual(prices[0].price, -0.002))
        #expect(almostEqual(prices[1].price, -0.002))
        #expect(almostEqual(prices[2].price, -0.00175))
        #expect(almostEqual(prices[13].price, 0.01317))
        #expect(almostEqual(prices[14].price, 0.01317))
        #expect(almostEqual(prices[15].price, 0.01342))
    }

    @Test
    func testFillMissingForPT15M() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-6-NO1-PT15M.xml")
        let prices = dayAheadPrices.timeSeries[0].period[0].fillMissingPrices()
        #expect(prices.count == 96)
        #expect(prices[92].priceAmount == 49.9)
        #expect(prices[93].priceAmount == 49.9)
        #expect(prices[94].priceAmount == 49.9)
        #expect(prices[95].priceAmount == 49.9)
    }

    @Test("PT60M is missing and should use the PT15M as fallback")
    func testMissingPT60MWithPT15MFallback() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-6-NO1-PT15M.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        #expect(prices.count == 24)
        #expect(prices[0].date.debugDescription == "2025-02-24 23:00:00 +0000")
        #expect(almostEqual(prices[0].price, 0.03883))
        #expect(prices[1].date.debugDescription == "2025-02-25 00:00:00 +0000")
        #expect(almostEqual(prices[1].price, 0.04299))
        #expect(prices[23].date.debugDescription == "2025-02-25 22:00:00 +0000")
        #expect(almostEqual(prices[23].price, 0.0499))
    }

    @Test("Both PT60M and PT15M prices for the same time period")
    func testBothPT60MAndPT15M() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-7-DE-LU.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        #expect(prices.count == 24)
        #expect(prices[0].date.debugDescription == "2025-02-24 23:00:00 +0000")
        #expect(almostEqual(prices[0].price, 0.0906))
        #expect(prices[1].date.debugDescription == "2025-02-25 00:00:00 +0000")
        #expect(almostEqual(prices[1].price, 0.08991))
        #expect(prices[23].date.debugDescription == "2025-02-25 22:00:00 +0000")
        #expect(almostEqual(prices[23].price, 0.11513))
    }

    @Test("Both PT15M and PT60M prices for different time periods")
    func testBothPT15MAndPT60MForDifferentDays() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-8-NO2-PT15M-PT60M.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        #expect(prices.count == 48)
        #expect(prices[0].date.debugDescription == "2025-02-24 23:00:00 +0000")
        #expect(almostEqual(prices[0].price, 0.04992))
        #expect(prices[47].date.debugDescription == "2025-02-26 22:00:00 +0000")
        #expect(almostEqual(prices[47].price, 0.05168))
    }

}
