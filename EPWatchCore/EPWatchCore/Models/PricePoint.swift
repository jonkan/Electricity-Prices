//
//  PricePoint.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import SwiftDate

public struct PricePoint: Codable, Equatable {
    public let date: Date // And 1h forward
    public let price: Double
    public let dayPriceRange: ClosedRange<Double>
    public let currency: Currency

    public init(
        date: Date,
        price: Double,
        dayPriceRange: ClosedRange<Double>,
        currency: Currency
    ) {
        self.date = date
        self.price = price
        self.dayPriceRange = dayPriceRange
        self.currency = currency
    }

    init(
        date: String,
        price: Double,
        dayPriceRange: ClosedRange<Double>,
        currency: Currency
    ) {
        self.date = ISO8601DateFormatter().date(from: date)!
        self.price = price
        self.dayPriceRange = dayPriceRange
        self.currency = currency
    }

    public func formattedPrice(
        _ style: FormattingStyle,
        _ currencyPresentation: CurrencyPresentation
    ) -> String {
        return currency.formatted(price, style, currencyPresentation)
    }

    public func formattedTimeInterval(_ style: FormattingStyle) -> String {
        return DateIntervalFormatter.formatted(
            from: date.convertTo(region: .current),
            to: date.convertTo(region: .current).dateByAdding(1, .hour),
            style: style
        )
    }
}

public extension PricePoint {
    static let mockPrice: PricePoint = [PricePoint].mockPrices[10]
    static let mockPrice2: PricePoint = [PricePoint].mockPrices[12]
    static let mockPrice3: PricePoint = [PricePoint].mockPrices[14]
}

public extension Array where Element == PricePoint {
    static let mockPrices: [PricePoint] = [
        PricePoint(date: "2022-09-18T22:00:00+0000", price: 0.342410544, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-18T23:00:00+0000", price: 0.319504311, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T00:00:00+0000", price: 0.298641357, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T01:00:00+0000", price: 0.274014467, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T02:00:00+0000", price: 0.300577095, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T03:00:00+0000", price: 0.348325299, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T04:00:00+0000", price: 1.279952981, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T05:00:00+0000", price: 2.844997155, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T06:00:00+0000", price: 4.359819681, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T07:00:00+0000", price: 3.726080568, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T08:00:00+0000", price: 3.421416914, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T09:00:00+0000", price: 2.421285615, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T10:00:00+0000", price: 2.002413420, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T11:00:00+0000", price: 1.609566146, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T12:00:00+0000", price: 1.469977929, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T13:00:00+0000", price: 1.290169377, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T14:00:00+0000", price: 1.204029035, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T15:00:00+0000", price: 3.593267432, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T16:00:00+0000", price: 4.085912754, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T17:00:00+0000", price: 4.193883918, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T18:00:00+0000", price: 3.226337541, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T19:00:00+0000", price: 0.349723332, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T20:00:00+0000", price: 0.261647252, dayPriceRange: 0.157547565...4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T21:00:00+0000", price: 0.157547565, dayPriceRange: 0.157547565...4.359819681, currency: .SEK)
    ].enumerated().map({ (i, p) in
        let h = TimeInterval(i * 60 * 60)
        return PricePoint(
            date: .now.dateAtStartOf(.day).addingTimeInterval(h),
            price: p.price,
            dayPriceRange: p.dayPriceRange,
            currency: p.currency
        )
    })

    static let mockPricesLow: [PricePoint] = [
        PricePoint(date: "2022-10-04T22:00:00+0000", price: 0.19459063, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-04T23:00:00+0000", price: 0.18366586, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T00:00:00+0000", price: 0.17890656, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T01:00:00+0000", price: 0.18301687, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T02:00:00+0000", price: 0.20378474, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T03:00:00+0000", price: 0.31368140, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T04:00:00+0000", price: 0.50513522, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T05:00:00+0000", price: 0.68068863, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T06:00:00+0000", price: 0.77252157, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T07:00:00+0000", price: 0.79242411, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T08:00:00+0000", price: 0.83190470, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T09:00:00+0000", price: 0.59318234, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T10:00:00+0000", price: 0.42119840, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T11:00:00+0000", price: 0.25462276, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T12:00:00+0000", price: 0.18572102, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T13:00:00+0000", price: 0.21070736, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T14:00:00+0000", price: 0.38853227, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T15:00:00+0000", price: 0.27787845, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T16:00:00+0000", price: 0.21838715, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T17:00:00+0000", price: 0.17295743, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T18:00:00+0000", price: 0.10924766, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T19:00:00+0000", price: 0.04813387, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T20:00:00+0000", price: 0.00086532, dayPriceRange: -0.00205515...0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T21:00:00+0000", price: -0.0020551, dayPriceRange: -0.00205515...0.83190470, currency: .SEK)
    ].enumerated().map({ (i, p) in
        let h = TimeInterval(i * 60 * 60)
        return PricePoint(
            date: .now.dateAtStartOf(.day).addingTimeInterval(h),
            price: p.price,
            dayPriceRange: p.dayPriceRange,
            currency: p.currency
        )
    })

    func price(for date: Date) -> PricePoint? {
        let d = date.in(region: .UTC)
        return first(where: {
            guard Calendar.current.isDate($0.date, inSameDayAs: date) else {
                return false
            }
            let s = $0.date.in(region: .UTC)
            return d.hour == s.hour
        })
    }

    func filterInSameDayAs(_ pricePoint: PricePoint, using calendar: Calendar = .current) -> [PricePoint] {
        filter({ calendar.isDate($0.date, inSameDayAs: pricePoint.date) })
    }

}
