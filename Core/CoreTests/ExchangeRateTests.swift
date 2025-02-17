//
//  Test.swift
//  Core
//
//  Created by Jonas Värbrand on 2025-01-20.
//

import Foundation
import Testing
@testable import Core

struct ExchangeRateTests {

    func dateInSweden(_ dateString: String) -> Date {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "Europe/Stockholm")
        df.locale = Locale(identifier: "sv_SE")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: dateString)!
    }

    @Test
    func testIsUpToDate() {
        let exchangeRate = ExchangeRate(
            date: "2025-02-06",
            from: .EUR,
            to: .SEK,
            rate: 11.321
        )
        #expect(exchangeRate.isUpToDate(at: dateInSweden("2025-02-07 08:00:00")))
    }

    @Test
    func testIsNotUpToDate() {
        let exchangeRate = ExchangeRate(
            date: "2025-02-06",
            from: .EUR,
            to: .SEK,
            rate: 11.321
        )
        #expect(!exchangeRate.isUpToDate(at: dateInSweden("2025-02-08 08:00:00")))
    }

    @Test
    func testIsUpToDateOnWeekends() {
        let exchangeRate = ExchangeRate(
            date: "2025-01-31",
            from: .EUR,
            to: .SEK,
            rate: 11.321
        )
        #expect(exchangeRate.isUpToDate(at: dateInSweden("2025-02-01 12:00:00")), "Up-to-date the following Saturday")
        #expect(exchangeRate.isUpToDate(at: dateInSweden("2025-02-02 08:00:00")), "Up-to-date the following Sunday")
    }

    @Test
    func testIsUpToDateOnAMonday() {
        let exchangeRate = ExchangeRate(
            date: "2025-01-31",
            from: .EUR,
            to: .SEK,
            rate: 11.321
        )
        #expect(
            exchangeRate.isUpToDate(at: dateInSweden("2025-02-03 08:00:00")),
            "Up-to-date the following Monday"
        )
        #expect(
            exchangeRate.isUpToDate(at: dateInSweden("2025-02-03 15:59:59")),
            "Up-to-date the following Monday before 16:00 CET"
        )
        #expect(
            !exchangeRate.isUpToDate(at: dateInSweden("2025-02-03 16:00:00")),
            "Not up-to-date the following Monday after 16:00 CET"
        )
    }

}
