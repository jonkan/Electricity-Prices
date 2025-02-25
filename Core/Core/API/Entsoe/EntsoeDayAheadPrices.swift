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
            throw NSError(0, "Unexpected exhange rate, prices must be converted from EUR")
        }

        let periods = timeSeries.flatMap { $0.period }
        let periodsByStartDate = Dictionary(grouping: periods, by: \.timeInterval.start)

        var pricePoints: [PricePoint] = []
        for (_, periods) in periodsByStartDate {
            if let pt60mPeriod = periods.first(where: { $0.resolution == "PT60M" }) {
                let periodPricePoints = pt60mPeriod.convertToPricePoints(resolution: 60, rate: rate)
                pricePoints.append(contentsOf: periodPricePoints)

            } else if let pt15mPeriod = periods.first(where: { $0.resolution == "PT15M" }) {
                // Derive the hourly prices from the quarterly prices, if constant.
                // Avoid calculating an average as that doesn't produce the correct prices,
                // e.g. PT15M vs. PT60M in day-ahead-prices-7-DE-LU.xml.
                let pt15mPricePoints = pt15mPeriod.convertToPricePoints(resolution: 15, rate: rate)
                let groupedPerHour = Dictionary(grouping: pt15mPricePoints) { pricePoint in
                    Calendar.current.startOfHour(for: pricePoint.date)
                }
                let isHourlyConstant = try groupedPerHour.values.allSatisfy { prices in
                    if prices.count != 4 {
                        throw NSError(0, "Unexpected PT15M series")
                    }
                    let sorted = prices.sorted(by: { $0.price < $1.price })
                    return sorted.first!.price == sorted.last!.price
                }

                if isHourlyConstant {
                    let pt60mPricePoints = groupedPerHour.map { date, prices in
                        PricePoint(
                            date: date,
                            price: prices.first!.price,
                            currency: rate.to
                        )
                    }
                    pricePoints.append(contentsOf: pt60mPricePoints)
                }
            }
        }

        return pricePoints.sorted(by: { $0.date < $1.date })
    }

}

extension EntsoeDayAheadPrices.Period {

    func convertToPricePoints(
        resolution minutesPerPoint: Int,
        rate: ExchangeRate
    ) -> [PricePoint] {
        var pricePoints: [PricePoint] = []
        let periodPoints = fillMissingPrices()

        for p in periodPoints {
            let start = Calendar.current.date(
                byAdding: .minute,
                value: (p.position - 1) * minutesPerPoint,
                to: timeInterval.start
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

        return pricePoints
    }

    /// Fill any blanks (missing prices) with the previous price, see CurveType A03 in the entsoe docs.
    func fillMissingPrices() -> [EntsoeDayAheadPrices.Point] {
        var points: [EntsoeDayAheadPrices.Point] = []
        var previous: EntsoeDayAheadPrices.Point?

        for point in self.point {
            if previous != nil {
                while point.position - previous!.position > 1 {
                    let fillPoint = EntsoeDayAheadPrices.Point(
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

        if resolution == "PT60M" {
            while let previous = points.last, points.count < 24 {
                let fillPoint = EntsoeDayAheadPrices.Point(
                    position: previous.position + 1,
                    priceAmount: previous.priceAmount
                )
                points.append(fillPoint)
            }
        } else if resolution == "PT15M" {
            while let previous = points.last, points.count < 96 {
                let fillPoint = EntsoeDayAheadPrices.Point(
                    position: previous.position + 1,
                    priceAmount: previous.priceAmount
                )
                points.append(fillPoint)
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
