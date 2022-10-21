//
//  EPWatch_WatchKit_ExtensionTests.swift
//  EPWatch WatchKit ExtensionTests
//
//  Created by Jonas Bromö on 2022-09-01.
//

import XCTest
@testable import EPWatch_WatchKit_Extension
import SwiftDate

class EPWatch_WatchKit_ExtensionTests: XCTestCase {

    lazy var bundle = Bundle(for: type(of: self))

    override func setUpWithError() throws {

    }

    func testDecodeDayAheadPrices1() throws {
        let url = bundle.url(forResource: "day-ahead-prices-1", withExtension: "xml")!
        let xmlData = try Data(contentsOf: url)
        let dayAheadPrices = try parseDayAheadPrices(fromXML: xmlData)
        XCTAssertEqual(dayAheadPrices.timeSeries.count, 2)
        XCTAssertEqual(dayAheadPrices.periodTimeInterval.start.debugDescription, "2022-08-25 22:00:00 +0000")
        XCTAssertEqual(dayAheadPrices.periodTimeInterval.end.debugDescription, "2022-08-27 22:00:00 +0000")
        XCTAssertEqual(dayAheadPrices.timeSeries[0].period.point[3].position, 4)
        XCTAssertEqual(dayAheadPrices.timeSeries[0].period.point[3].priceAmount, 8.18)
    }

    func testFindPriceAmount() throws {
        let url = bundle.url(forResource: "day-ahead-prices-1", withExtension: "xml")!
        let xmlData = try Data(contentsOf: url)
        let dayAheadPrices = try parseDayAheadPrices(fromXML: xmlData)

        let region = Region(calendar: Calendars.gregorian, zone: Zones.europeStockholm, locale: Locales.swedish)
        let date1 = DateInRegion("2022-08-26 08:00:00", region: region)!.date
        let price = try dayAheadPrices.priceAmount(for: date1)
        XCTAssertEqual(price, 619.96)
    }

}
