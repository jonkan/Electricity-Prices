//
//  EntsoeDayAheadPrices.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation

struct EntsoeDayAheadPrices: Codable {
    var timeSeries: [TimeSeries]
    var periodTimeInterval: TimeInterval

    enum CodingKeys: String, CodingKey {
        case timeSeries
        case periodTimeInterval = "period.timeInterval"
    }

    struct TimeSeries: Codable {
        var period: [Period]
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

    func prices(using rate: ExchangeRate) throws -> [PricePoint] {
        guard rate.from == .EUR else {
            throw NSError(0, "Unexpected forex rate, prices must be converted from EUR")
        }
        var pricePoints: [PricePoint] = []
        for ts in timeSeries {
            for period in ts.period {
                guard period.resolution == "PT60M" else {
                    continue
                }

                let periodPoints = period.point.fillMissingPrices()

                for p in periodPoints {
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
                        currency: rate.to
                    )
                    pricePoints.append(pricePoint)
                }
            }
        }
        return pricePoints.sorted(by: { $0.date < $1.date })
    }

}

private typealias Point = EntsoeDayAheadPrices.Point

extension Array where Element == Point {

    /// Fill any blanks (missing prices) with the previous price, see CurveType A03 in the entsoe docs.
    func fillMissingPrices() -> [Element] {
        var points: [Point] = []
        var previous: Point?
        for point in self {
            if previous != nil {
                while point.position - previous!.position > 1 {
                    let fillPoint = Point(
                        position: previous!.position + 1,
                        priceAmount: previous!.priceAmount
                    )
                    points.append(fillPoint)
                    previous = fillPoint
                }
            }
            points.append(point)
            previous = point
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

// swiftlint:disable force_try
extension EntsoeDayAheadPrices {
    static let mocked1: EntsoeDayAheadPrices = {
        let fileURL = Bundle.module
            .url(forResource: "mocked-day-ahead-prices-1", withExtension: "xml")!
        let xmlData = try! Data(contentsOf: fileURL)
        let prices = try! EntsoePricesAPI.shared.parseDayAheadPrices(fromXML: xmlData)
        return prices
    }()
}
// swiftlint:enable force_try
