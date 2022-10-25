//
//  EPWatchCoreTests.swift
//  EPWatchCoreTests
//
//  Created by Jonas Bromö on 2022-09-13.
//

import XCTest
@testable import EPWatchCore
import SwiftDate

final class EPWatchCoreTests: XCTestCase {

    lazy var bundle = Bundle(for: type(of: self))

    var dayAheadPrices: DayAheadPrices!
    let swedishRegion = Region(
        calendar: Calendars.gregorian,
        zone: Zones.europeStockholm,
        locale: Locales.swedish
    )

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
        let date1 = DateInRegion("2022-08-26 08:00:00", region: swedishRegion)!.date
        let price = try dayAheadPrices.price(for: date1)
        XCTAssertEqual(price, 619.96)
    }

    func testPrices1() throws {
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        let date1 = DateInRegion("2022-08-26 08:00:00", region: swedishRegion)!.date
        XCTAssertEqual(prices.price(for: date1)!.price, 0.61996, accuracy: 1e-10)
    }

    func testPrices2() throws {
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        let date1 = DateInRegion("2022-08-26 14:33:00", region: swedishRegion)!.date
        XCTAssertEqual(prices.price(for: date1)!.price, 0.62810, accuracy: 1e-10)
    }

    func testPricesOrderedChronologically() throws {
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
        XCTAssertTrue(prices.first!.date < prices.last!.date)
    }

    func testDayPriceRange() throws {
        let dayStart = DateInRegion("2022-08-26 00:00:00", region: swedishRegion)!.date
        let dayEnd = DateInRegion("2022-08-26 24:00:00", region: swedishRegion)!.date
        let prices = try dayAheadPrices.prices(using: .mockedEUR)
            .filter({
                dayStart <= $0.date && $0.date < dayEnd })
        XCTAssertEqual(prices.count, 24)
        let ranges = prices.map({ $0.dayPriceRange }).sorted(by: { $0.lowerBound < $1.lowerBound })
        XCTAssertEqual(ranges.first, ranges.last)
    }

}
