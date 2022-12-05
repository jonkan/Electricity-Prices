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
        let url = bundle.url(forResource: "day-ahead-prices-1", withExtension: "xml")!
        let xmlData = try Data(contentsOf: url)
        dayAheadPrices = try PricesAPI.shared.parseDayAheadPrices(fromXML: xmlData)
    }

    func testDecodeDayAheadPrices1() throws {
        XCTAssertEqual(dayAheadPrices.timeSeries.count, 2)
        XCTAssertEqual(dayAheadPrices.periodTimeInterval.start.debugDescription, "2022-08-25 22:00:00 +0000")
        XCTAssertEqual(dayAheadPrices.periodTimeInterval.end.debugDescription, "2022-08-27 22:00:00 +0000")
        XCTAssertEqual(dayAheadPrices.timeSeries[0].period.point[3].position, 4)
        XCTAssertEqual(dayAheadPrices.timeSeries[0].period.point[3].priceAmount, 8.18)
    }

    func testFindPriceAmount() throws {
        let date1 = swedishDateFormatter.date(from: "2022-08-26 08:00:00")!
        let price = try dayAheadPrices.price(for: date1)
        XCTAssertEqual(price, 619.96)
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

    func testDayPriceRange() throws {
        let dayStart = swedishDateFormatter.date(from: "2022-08-26 00:00:00")!
        let dayEnd = swedishDateFormatter.date(from: "2022-08-27 00:00:00")!
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
            .filter({
                dayStart <= $0.date && $0.date < dayEnd })
        XCTAssertEqual(prices.count, 24)
        let ranges = prices.map({ $0.dayPriceRange }).sorted(by: { $0.lowerBound < $1.lowerBound })
        XCTAssertEqual(ranges.first, ranges.last)
    }

}
