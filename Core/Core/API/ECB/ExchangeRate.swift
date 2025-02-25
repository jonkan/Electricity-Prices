//
//  ExchangeRate.swift
//  Core
//
//  Created by Jonas Bromö on 2022-10-24.
//

import Foundation

public struct ExchangeRate: Codable, Equatable, Sendable {
    static private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "UTC")
        return df
    }()

    public let date: String // "2022-09-07"
    public let from: Currency
    public let to: Currency
    public let rate: Double // 10.700151

    private var parsedDate: Date? {
        Self.dateFormatter.date(from: date)
    }

    /// This is a simple best-effort check to answer if this exchange rate is the latest one available.
    /// E.g. on a Monday, before 16:00 CET, the most recent exchange rate is from last Friday
    /// (provided that wasn't a holiday, which we don't handle).
    /// See https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html
    func isUpToDate(at date: Date = .now) -> Bool {
        let exchangeRateDate = parsedDate ?? .distantPast
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "CET")!
        let daysAgo = calendar.dateComponents([.day], from: exchangeRateDate, to: date).day ?? .max
        let fromAFriday = calendar.component(.weekday, from: exchangeRateDate) == 6 // Doc: Sunday is 1
        let fromLastFriday = fromAFriday && daysAgo < 7
        let dateIsBefore16CET = date < date.atCET(hour: 16)

        // If it's from today it's up-to-date.
        if daysAgo <= 0 {
            return true
        }

        // If it's before 16:00 CET, the most recent exchange rate is from yesterday.
        if dateIsBefore16CET && daysAgo <= 1 {
            return true
        }

        // If it's Saturday or Sunday, the most recent exchange rate is from last friday.
        if  fromLastFriday && daysAgo <= 2 {
            return true
        }

        // If it's Monday before 16:00 CET, the most recent exchange rate is from last friday.
        if fromLastFriday && daysAgo <= 3 && dateIsBefore16CET {
            return true
        }

        // There's more corner cases that we don't care about here.
        return false
    }

}

extension ExchangeRate {
    static private let rateNumberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumSignificantDigits = 4
        nf.minimumSignificantDigits = 4
        return nf
    }()

    public func formattedRate() -> String? {
        return Self.rateNumberFormatter.string(from: rate as NSNumber)
    }

    static private let presentationDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    public func formattedDate() -> String {
        guard let parsedDate = parsedDate else {
            return ""
        }
        return Self.presentationDateFormatter.string(from: parsedDate)
    }
}

extension ExchangeRate {
    public static let mockedSEK = ExchangeRate(
        date: "2022-09-07",
        from: .EUR,
        to: .SEK,
        rate: 10.700151
    )
    public static var mockedEUR: ExchangeRate {
        ExchangeRate(
            date: "2022-09-07",
            from: .EUR,
            to: .EUR,
            rate: 1
        )
    }

    // swiftlint:disable cyclomatic_complexity
    static func mockedEUR(to: Currency) -> ExchangeRate {
        let rate: Double
        switch to {
//        case .ALL: rate = 0.0
//        case .BAM: rate = 0.0
        case .BGN: rate = 1.9558
        case .CHF: rate = 0.9779
        case .CZK: rate = 25.164
        case .DKK: rate = 7.4573
        case .EUR: rate = 1
        case .GBP: rate = 0.85643
//        case .GEL: rate = 0.0
//        case .HRK: rate = 0.0
        case .HUF: rate = 392.28
//        case .MDL: rate = 0.0
//        case .MKD: rate = 0.0
        case .NOK: rate = 11.7995
        case .PLN: rate = 4.3205
        case .RON: rate = 4.9764
//        case .RSD: rate = 0.0
        case .SEK: rate = 11.7052
        case .TRY: rate = 34.8036
//        case .UAH: rate = 0.0
        }
        return ExchangeRate(
            date: "2024-04-26",
            from: .EUR,
            to: to,
            rate: rate
        )
    }
}
