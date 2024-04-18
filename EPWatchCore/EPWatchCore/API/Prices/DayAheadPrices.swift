//
//  DayAheadPrices.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation

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
                let calendar = Calendar.current
                guard let start = calendar.date(byAdding: .hour, value: p.position - 1, to: timeInterval.start),
                      let end = calendar.date(byAdding: .hour, value: 1, to: start) else {
                    LogError("Failed to construct start/end time")
                    return false
                }
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

    func prices(using rate: ExchangeRate) throws -> [PricePoint] {
        guard rate.from == .EUR else {
            throw NSError(0, "Unexpected forex rate, prices must be converted from EUR")
        }
        var points: [PricePoint] = []
        for ts in timeSeries {
            let period = ts.period
            guard period.resolution == "PT60M" else {
                continue
            }
            for p in period.point {
                let start = Calendar.current.date(
                    byAdding: .hour,
                    value: p.position - 1,
                    to: period.timeInterval.start
                )!
                let MWperkW = 0.001
                let price = p.priceAmount * rate.rate * MWperkW
                let pricePoint = PricePoint(
                    date: start,
                    price: price,
                    dayPriceRange: price...price,
                    currency: rate.to
                )
                points.append(pricePoint)
            }
        }

        let grouped = Dictionary(
            grouping: points,
            by: { Calendar.current.startOfDay(for: $0.date) }
        )
        var pricePoints: [PricePoint] = []
        for (startOfDay, prices) in grouped {
            guard let priceRange = prices.priceRange(forDayOf: startOfDay) else {
                LogError("Failed to calculate price range")
                continue
            }
            pricePoints.append(
                contentsOf: prices.map({
                    PricePoint(
                        date: $0.date,
                        price: $0.price,
                        dayPriceRange: priceRange,
                        currency: rate.to
                    )
                })
            )
        }
        return pricePoints.sorted(by: { $0.date < $1.date })
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
