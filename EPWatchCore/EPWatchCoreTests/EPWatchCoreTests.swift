//
//  EPWatchCoreTests.swift
//  EPWatchCoreTests
//
//  Created by Jonas Bromö on 2022-09-13.
//

import XCTest
@testable import EPWatchCore

final class EPWatchCoreTests: XCTestCase {

    lazy var bundle: Bundle = {
        let bundleURL = Bundle(for: type(of: self))
            .bundleURL
            .appending(path: "EPWatchCore_EPWatchCoreTests.bundle")
        return Bundle(url: bundleURL)!
    }()

    var dayAheadPrices: DayAheadPrices!
    let swedishDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "Europe/Stockholm")
        df.locale = Locale(identifier: "sv_SE")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()

    override func setUpWithError() throws {
        dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-1.xml")
    }

    func loadDayAheadPrices(_ filename: String) throws -> DayAheadPrices {
        let url = bundle.url(forResource: filename, withExtension: nil)!
        let xmlData = try Data(contentsOf: url)
        return try PricesAPI.shared.parseDayAheadPrices(fromXML: xmlData)
    }

    func testDecodeDayAheadPrices1() throws {
        XCTAssertEqual(dayAheadPrices.timeSeries.count, 2)
        XCTAssertEqual(dayAheadPrices.periodTimeInterval.start.debugDescription, "2022-08-25 22:00:00 +0000")
        XCTAssertEqual(dayAheadPrices.periodTimeInterval.end.debugDescription, "2022-08-27 22:00:00 +0000")
        XCTAssertEqual(dayAheadPrices.timeSeries[0].period[0].point[3].position, 4)
        XCTAssertEqual(dayAheadPrices.timeSeries[0].period[0].point[3].priceAmount, 8.18)
    }

    func testPrices1() throws {
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        let date1 = swedishDateFormatter.date(from: "2022-08-26 08:00:00")!
        XCTAssertEqual(prices.price(for: date1)!.price, 0.61996, accuracy: 1e-10)
    }

    func testPrices2() throws {
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        let date1 = swedishDateFormatter.date(from: "2022-08-26 14:33:00")!
        XCTAssertEqual(prices.price(for: date1)!.price, 0.62810, accuracy: 1e-10)
    }

    func testPricesOrderedChronologically() throws {
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        XCTAssertTrue(prices.first!.date < prices.last!.date)
    }

    func testMultiplePeriods() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-4.xml")
        let lastDate = try dayAheadPrices.prices(using: .mockedSEK).last!.date
        let day = Calendar.current.component(.day, from: lastDate)
        XCTAssertEqual(day, 6)
    }

    func testA03CurveType() throws {
        let dayAheadPrices = try loadDayAheadPrices("day-ahead-prices-5.xml")
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        XCTAssertEqual(prices.count, 24)
        XCTAssertEqual(prices[0].price, -0.002, accuracy: 1e-10)
        XCTAssertEqual(prices[1].price, -0.002, accuracy: 1e-10)
        XCTAssertEqual(prices[2].price, -0.00175, accuracy: 1e-10)
        XCTAssertEqual(prices[13].price, 0.01317, accuracy: 1e-10)
        XCTAssertEqual(prices[14].price, 0.01317, accuracy: 1e-10)
        XCTAssertEqual(prices[15].price, 0.01342, accuracy: 1e-10)
    }

}
