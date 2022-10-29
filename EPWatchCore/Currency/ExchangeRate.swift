//
//  ExchangeRate.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-24.
//

import Foundation

public struct ExchangeRate: Codable {
    static private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    public let date: String // "2022-09-07"
    public let from: Currency
    public let to: Currency
    public let rate: Double // 10.700151

    var parsedDate: Date? {
        Self.dateFormatter.date(from: date)
    }

    var isUpToDate: Bool {
        let d = parsedDate ?? .distantPast
        let friday = 6 // Doc: Sunday is 1
        let cal = Calendar.current
        return (
            cal.isDateInToday(d) ||
            (
                cal.isDateInWeekend(.now) &&
                cal.component(.weekday, from: d) == friday
            )
        )
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
}
