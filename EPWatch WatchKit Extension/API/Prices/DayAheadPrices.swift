//
//  DayAheadPrices.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation
import SwiftDate

struct DayAheadPrices: Codable {
    var timeSeries: [TimeSeries]
    var periodTimeInterval: TimeInterval

    enum CodingKeys: String, CodingKey {
        case timeSeries
        case periodTimeInterval = "period.timeInterval"
    }

    struct TimeSeries: Codable {
        var period: Period
    }

    struct Period: Codable {
        var point: [Point]
        var timeInterval: TimeInterval
        var resolution: String

        func point(for date: Date) -> Point? {
            return point.first(where: { p in
                let start = timeInterval.start + (p.position - 1).hours
                let end = start + 1.hours
                return TimeInterval(start: start, end: end).includes(date)
            })
        }
    }

    struct Point: Codable {
        var position: Int
        var priceAmount: Double

        enum CodingKeys: String, CodingKey {
            case position
            case priceAmount = "price.amount"
        }
    }

    struct TimeInterval: Codable {
        var start: Date
        var end: Date

        func includes(_ date: Date) -> Bool {
            return start <= date && date < end
        }
    }

    func price(for date: Date) throws -> Double {
        guard periodTimeInterval.includes(date) else {
            throw DayAheadPricesError.dateOutsideTimeInterval
        }
        guard let timeSeries = timeSeries.first(where: { $0.period.timeInterval.includes(date) }) else {
            throw DayAheadPricesError.noTimeSeriesMatchingDate
        }
        guard let point = timeSeries.period.point(for: date) else {
            throw DayAheadPricesError.noPointMatchingDate
        }
        return point.priceAmount
    }

    func prices(using eurExchangeRate: Double) -> [PricePoint] {
        var points: [PricePoint] = []
        for ts in timeSeries {
            let period = ts.period
            for p in period.point {
                let start = period.timeInterval.start + (p.position - 1).hours
                let MWperkW = 0.001
                let price = p.priceAmount * eurExchangeRate * MWperkW
                points.append(PricePoint(price: price, start: start))
            }
        }
        return points
    }
}

enum DayAheadPricesError: Error {
    case dateOutsideTimeInterval
    case noTimeSeriesMatchingDate
    case noPointMatchingDate

    var description: String {
        switch self {
        case .dateOutsideTimeInterval:
            return "Date is outside time interval"
        case .noTimeSeriesMatchingDate:
            return "No time series matched included the date"
        case .noPointMatchingDate:
            return "No point matched the date"
        }
    }
}
