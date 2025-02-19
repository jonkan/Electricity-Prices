//
//  PricePoint.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation

public struct PricePoint: Codable, Equatable, FormattablePrice, Sendable {
    public let date: Date // And 1h forward
    public let price: Double
    public let currency: Currency

    public init(
        date: Date,
        price: Double,
        currency: Currency
    ) {
        self.date = date
        self.price = price
        self.currency = currency
    }

    init(
        date: String,
        price: Double,
        currency: Currency
    ) {
        self.date = ISO8601DateFormatter().date(from: date)!
        self.price = price
        self.currency = currency
    }

}

public extension PricePoint {
    static let mockedPrice: PricePoint = [PricePoint].mockedPrices[10]
    static let mockedPrice2: PricePoint = [PricePoint].mockedPrices[12]
    static let mockedPrice3: PricePoint = [PricePoint].mockedPrices[14]
    static let mockedPrice4Negative: PricePoint = [PricePoint].mockedPricesLow.last!
}

public extension Array where Element == PricePoint {
    static let mockedPrices: [PricePoint] = [
        PricePoint(date: "2022-09-18T22:00:00+0000", price: 0.342410544, currency: .SEK),
        PricePoint(date: "2022-09-18T23:00:00+0000", price: 0.319504311, currency: .SEK),
        PricePoint(date: "2022-09-19T00:00:00+0000", price: 0.298641357, currency: .SEK),
        PricePoint(date: "2022-09-19T01:00:00+0000", price: 0.274014467, currency: .SEK),
        PricePoint(date: "2022-09-19T02:00:00+0000", price: 0.300577095, currency: .SEK),
        PricePoint(date: "2022-09-19T03:00:00+0000", price: 0.348325299, currency: .SEK),
        PricePoint(date: "2022-09-19T04:00:00+0000", price: 1.279952981, currency: .SEK),
        PricePoint(date: "2022-09-19T05:00:00+0000", price: 2.844997155, currency: .SEK),
        PricePoint(date: "2022-09-19T06:00:00+0000", price: 4.359819681, currency: .SEK),
        PricePoint(date: "2022-09-19T07:00:00+0000", price: 3.726080568, currency: .SEK),
        PricePoint(date: "2022-09-19T08:00:00+0000", price: 3.421416914, currency: .SEK),
        PricePoint(date: "2022-09-19T09:00:00+0000", price: 2.421285615, currency: .SEK),
        PricePoint(date: "2022-09-19T10:00:00+0000", price: 2.002413420, currency: .SEK),
        PricePoint(date: "2022-09-19T11:00:00+0000", price: 1.609566146, currency: .SEK),
        PricePoint(date: "2022-09-19T12:00:00+0000", price: 1.469977929, currency: .SEK),
        PricePoint(date: "2022-09-19T13:00:00+0000", price: 1.290169377, currency: .SEK),
        PricePoint(date: "2022-09-19T14:00:00+0000", price: 1.204029035, currency: .SEK),
        PricePoint(date: "2022-09-19T15:00:00+0000", price: 3.593267432, currency: .SEK),
        PricePoint(date: "2022-09-19T16:00:00+0000", price: 4.085912754, currency: .SEK),
        PricePoint(date: "2022-09-19T17:00:00+0000", price: 4.193883918, currency: .SEK),
        PricePoint(date: "2022-09-19T18:00:00+0000", price: 3.226337541, currency: .SEK),
        PricePoint(date: "2022-09-19T19:00:00+0000", price: 0.349723332, currency: .SEK),
        PricePoint(date: "2022-09-19T20:00:00+0000", price: 0.261647252, currency: .SEK),
        PricePoint(date: "2022-09-19T21:00:00+0000", price: 0.157547565, currency: .SEK)
    ].shiftDatesToNow()

    static let mockedPricesLow: [PricePoint] = [
        PricePoint(date: "2022-10-04T22:00:00+0000", price: 0.19459063, currency: .SEK),
        PricePoint(date: "2022-10-04T23:00:00+0000", price: 0.18366586, currency: .SEK),
        PricePoint(date: "2022-10-05T00:00:00+0000", price: 0.17890656, currency: .SEK),
        PricePoint(date: "2022-10-05T01:00:00+0000", price: 0.18301687, currency: .SEK),
        PricePoint(date: "2022-10-05T02:00:00+0000", price: 0.20378474, currency: .SEK),
        PricePoint(date: "2022-10-05T03:00:00+0000", price: 0.31368140, currency: .SEK),
        PricePoint(date: "2022-10-05T04:00:00+0000", price: 0.50513522, currency: .SEK),
        PricePoint(date: "2022-10-05T05:00:00+0000", price: 0.68068863, currency: .SEK),
        PricePoint(date: "2022-10-05T06:00:00+0000", price: 0.77252157, currency: .SEK),
        PricePoint(date: "2022-10-05T07:00:00+0000", price: 0.79242411, currency: .SEK),
        PricePoint(date: "2022-10-05T08:00:00+0000", price: 0.83190470, currency: .SEK),
        PricePoint(date: "2022-10-05T09:00:00+0000", price: 0.59318234, currency: .SEK),
        PricePoint(date: "2022-10-05T10:00:00+0000", price: 0.42119840, currency: .SEK),
        PricePoint(date: "2022-10-05T11:00:00+0000", price: 0.25462276, currency: .SEK),
        PricePoint(date: "2022-10-05T12:00:00+0000", price: 0.18572102, currency: .SEK),
        PricePoint(date: "2022-10-05T13:00:00+0000", price: 0.21070736, currency: .SEK),
        PricePoint(date: "2022-10-05T14:00:00+0000", price: 0.38853227, currency: .SEK),
        PricePoint(date: "2022-10-05T15:00:00+0000", price: 0.27787845, currency: .SEK),
        PricePoint(date: "2022-10-05T16:00:00+0000", price: 0.21838715, currency: .SEK),
        PricePoint(date: "2022-10-05T17:00:00+0000", price: 0.17295743, currency: .SEK),
        PricePoint(date: "2022-10-05T18:00:00+0000", price: 0.10924766, currency: .SEK),
        PricePoint(date: "2022-10-05T19:00:00+0000", price: 0.04813387, currency: .SEK),
        PricePoint(date: "2022-10-05T20:00:00+0000", price: 0.00086532, currency: .SEK),
        PricePoint(date: "2022-10-05T21:00:00+0000", price: -0.0020551, currency: .SEK)
    ].shiftDatesToNow()

    static let mockedPricesWithTomorrow: [PricePoint] = [
        PricePoint(date: "2022-11-27T23:00:00+0000", price: 1.3644039, currency: .SEK),
        PricePoint(date: "2022-11-28T00:00:00+0000", price: 1.3675413, currency: .SEK),
        PricePoint(date: "2022-11-28T01:00:00+0000", price: 1.3248090, currency: .SEK),
        PricePoint(date: "2022-11-28T02:00:00+0000", price: 1.2489727, currency: .SEK),
        PricePoint(date: "2022-11-28T03:00:00+0000", price: 1.2587092, currency: .SEK),
        PricePoint(date: "2022-11-28T04:00:00+0000", price: 1.2990614, currency: .SEK),
        PricePoint(date: "2022-11-28T05:00:00+0000", price: 1.5905064, currency: .SEK),
        PricePoint(date: "2022-11-28T06:00:00+0000", price: 1.9689306, currency: .SEK),
        PricePoint(date: "2022-11-28T07:00:00+0000", price: 2.2077986, currency: .SEK),
        PricePoint(date: "2022-11-28T08:00:00+0000", price: 2.2371162, currency: .SEK),
        PricePoint(date: "2022-11-28T09:00:00+0000", price: 2.4661396, currency: .SEK),
        PricePoint(date: "2022-11-28T10:00:00+0000", price: 2.5227193, currency: .SEK),
        PricePoint(date: "2022-11-28T11:00:00+0000", price: 2.5138483, currency: .SEK),
        PricePoint(date: "2022-11-28T12:00:00+0000", price: 2.5135238, currency: .SEK),
        PricePoint(date: "2022-11-28T13:00:00+0000", price: 2.5131992, currency: .SEK),
        PricePoint(date: "2022-11-28T14:00:00+0000", price: 2.5195820, currency: .SEK),
        PricePoint(date: "2022-11-28T15:00:00+0000", price: 2.6555681, currency: .SEK),
        PricePoint(date: "2022-11-28T16:00:00+0000", price: 2.7043586, currency: .SEK),
        PricePoint(date: "2022-11-28T17:00:00+0000", price: 2.6088330, currency: .SEK),
        PricePoint(date: "2022-11-28T18:00:00+0000", price: 2.3775377, currency: .SEK),
        PricePoint(date: "2022-11-28T19:00:00+0000", price: 2.1885420, currency: .SEK),
        PricePoint(date: "2022-11-28T20:00:00+0000", price: 2.0568833, currency: .SEK),
        PricePoint(date: "2022-11-28T21:00:00+0000", price: 1.9216546, currency: .SEK),
        PricePoint(date: "2022-11-28T22:00:00+0000", price: 1.5298158, currency: .SEK),
        PricePoint(date: "2022-11-28T23:00:00+0000", price: 2.2681647, currency: .SEK),
        PricePoint(date: "2022-11-29T00:00:00+0000", price: 2.2169942, currency: .SEK),
        PricePoint(date: "2022-11-29T01:00:00+0000", price: 2.2710857, currency: .SEK),
        PricePoint(date: "2022-11-29T02:00:00+0000", price: 2.2693547, currency: .SEK),
        PricePoint(date: "2022-11-29T03:00:00+0000", price: 2.2709775, currency: .SEK),
        PricePoint(date: "2022-11-29T04:00:00+0000", price: 2.4018789, currency: .SEK),
        PricePoint(date: "2022-11-29T05:00:00+0000", price: 2.8091879, currency: .SEK),
        PricePoint(date: "2022-11-29T06:00:00+0000", price: 4.1835447, currency: .SEK),
        PricePoint(date: "2022-11-29T07:00:00+0000", price: 4.7984569, currency: .SEK),
        PricePoint(date: "2022-11-29T08:00:00+0000", price: 4.8176053, currency: .SEK),
        PricePoint(date: "2022-11-29T09:00:00+0000", price: 4.8239881, currency: .SEK),
        PricePoint(date: "2022-11-29T10:00:00+0000", price: 4.7124514, currency: .SEK),
        PricePoint(date: "2022-11-29T11:00:00+0000", price: 4.5225903, currency: .SEK),
        PricePoint(date: "2022-11-29T12:00:00+0000", price: 4.5897719, currency: .SEK),
        PricePoint(date: "2022-11-29T13:00:00+0000", price: 4.8290727, currency: .SEK),
        PricePoint(date: "2022-11-29T14:00:00+0000", price: 4.8758078, currency: .SEK),
        PricePoint(date: "2022-11-29T15:00:00+0000", price: 4.9768507, currency: .SEK),
        PricePoint(date: "2022-11-29T16:00:00+0000", price: 5.4210501, currency: .SEK),
        PricePoint(date: "2022-11-29T17:00:00+0000", price: 5.2669975, currency: .SEK),
        PricePoint(date: "2022-11-29T18:00:00+0000", price: 4.8973362, currency: .SEK),
        PricePoint(date: "2022-11-29T19:00:00+0000", price: 4.2234643, currency: .SEK),
        PricePoint(date: "2022-11-29T20:00:00+0000", price: 3.5644134, currency: .SEK),
        PricePoint(date: "2022-11-29T21:00:00+0000", price: 3.1428243, currency: .SEK),
        PricePoint(date: "2022-11-29T22:00:00+0000", price: 2.8379646, currency: .SEK)
    ].shiftDatesToNow()

    static let mockedPricesWithTomorrow2: [PricePoint] = [
        PricePoint(date: "2024-11-04T23:00:00+0000", price: 0.2508225, currency: .SEK),
        PricePoint(date: "2024-11-05T00:00:00+0000", price: 0.0763879, currency: .SEK),
        PricePoint(date: "2024-11-05T01:00:00+0000", price: 0.0739425, currency: .SEK),
        PricePoint(date: "2024-11-05T02:00:00+0000", price: 0.0617158, currency: .SEK),
        PricePoint(date: "2024-11-05T03:00:00+0000", price: 0.0646269, currency: .SEK),
        PricePoint(date: "2024-11-05T04:00:00+0000", price: 0.4534368, currency: .SEK),
        PricePoint(date: "2024-11-05T05:00:00+0000", price: 0.9966527, currency: .SEK),
        PricePoint(date: "2024-11-05T06:00:00+0000", price: 1.4066556, currency: .SEK),
        PricePoint(date: "2024-11-05T07:00:00+0000", price: 1.3470357, currency: .SEK),
        PricePoint(date: "2024-11-05T08:00:00+0000", price: 1.1507094, currency: .SEK),
        PricePoint(date: "2024-11-05T09:00:00+0000", price: 1.0317027, currency: .SEK),
        PricePoint(date: "2024-11-05T10:00:00+0000", price: 0.9277173, currency: .SEK),
        PricePoint(date: "2024-11-05T11:00:00+0000", price: 0.9253884, currency: .SEK),
        PricePoint(date: "2024-11-05T12:00:00+0000", price: 0.9498418, currency: .SEK),
        PricePoint(date: "2024-11-05T13:00:00+0000", price: 1.0424156, currency: .SEK),
        PricePoint(date: "2024-11-05T14:00:00+0000", price: 1.2593526, currency: .SEK),
        PricePoint(date: "2024-11-05T15:00:00+0000", price: 1.8171242, currency: .SEK),
        PricePoint(date: "2024-11-05T16:00:00+0000", price: 2.5135817, currency: .SEK),
        PricePoint(date: "2024-11-05T17:00:00+0000", price: 1.8205011, currency: .SEK),
        PricePoint(date: "2024-11-05T18:00:00+0000", price: 1.0121399, currency: .SEK),
        PricePoint(date: "2024-11-05T19:00:00+0000", price: 0.8358422, currency: .SEK),
        PricePoint(date: "2024-11-05T20:00:00+0000", price: 0.7964838, currency: .SEK),
        PricePoint(date: "2024-11-05T21:00:00+0000", price: 0.5224887, currency: .SEK),
        PricePoint(date: "2024-11-05T22:00:00+0000", price: 0.2892493, currency: .SEK),
        PricePoint(date: "2024-11-05T23:00:00+0000", price: 0.1264592, currency: .SEK),
        PricePoint(date: "2024-11-06T00:00:00+0000", price: 0.0739425, currency: .SEK),
        PricePoint(date: "2024-11-06T01:00:00+0000", price: 0.0782510, currency: .SEK),
        PricePoint(date: "2024-11-06T02:00:00+0000", price: 0.0922244, currency: .SEK),
        PricePoint(date: "2024-11-06T03:00:00+0000", price: 0.0989782, currency: .SEK),
        PricePoint(date: "2024-11-06T04:00:00+0000", price: 0.4467994, currency: .SEK),
        PricePoint(date: "2024-11-06T05:00:00+0000", price: 0.6404475, currency: .SEK),
        PricePoint(date: "2024-11-06T06:00:00+0000", price: 1.8175900, currency: .SEK),
        PricePoint(date: "2024-11-06T07:00:00+0000", price: 1.7202419, currency: .SEK),
        PricePoint(date: "2024-11-06T08:00:00+0000", price: 1.2964986, currency: .SEK),
        PricePoint(date: "2024-11-06T09:00:00+0000", price: 1.0974941, currency: .SEK),
        PricePoint(date: "2024-11-06T10:00:00+0000", price: 0.9018665, currency: .SEK),
        PricePoint(date: "2024-11-06T11:00:00+0000", price: 0.9584587, currency: .SEK),
        PricePoint(date: "2024-11-06T12:00:00+0000", price: 1.1847114, currency: .SEK),
        PricePoint(date: "2024-11-06T13:00:00+0000", price: 1.3055813, currency: .SEK),
        PricePoint(date: "2024-11-06T14:00:00+0000", price: 1.3832501, currency: .SEK),
        PricePoint(date: "2024-11-06T15:00:00+0000", price: 1.3646189, currency: .SEK),
        PricePoint(date: "2024-11-06T16:00:00+0000", price: 2.3627854, currency: .SEK),
        PricePoint(date: "2024-11-06T17:00:00+0000", price: 1.4795501, currency: .SEK),
        PricePoint(date: "2024-11-06T18:00:00+0000", price: 1.0809589, currency: .SEK),
        PricePoint(date: "2024-11-06T19:00:00+0000", price: 0.7156709, currency: .SEK),
        PricePoint(date: "2024-11-06T20:00:00+0000", price: 0.5822250, currency: .SEK),
        PricePoint(date: "2024-11-06T21:00:00+0000", price: 0.5222558, currency: .SEK),
        PricePoint(date: "2024-11-06T22:00:00+0000", price: 0.2502403, currency: .SEK)
    ].shiftDatesToNow()

    func price(for date: Date) -> PricePoint? {
        let hour = Calendar.current.component(.hour, from: date)
        return first(where: {
            guard Calendar.current.isDate($0.date, inSameDayAs: date) else {
                return false
            }
            return hour == Calendar.current.component(.hour, from: $0.date)
        })
    }

    func filterInSameDay(as date: Date = .now, using calendar: Calendar = .current) -> [PricePoint] {
        filter({ calendar.isDate($0.date, inSameDayAs: date) })
    }

    /// Filters prices in the same day as 'date' and the first 8 hours of the next day
    func filterInSameDayAndComingNight(as date: Date = .now, using calendar: Calendar = .current) -> [PricePoint] {
        let todaysPrices = filterInSameDay(as: date, using: calendar)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
        let tomorrowsPrices = filterInSameDay(as: nextDay, using: calendar)
        let nightsPrices = tomorrowsPrices.count >= 8 ? Array(tomorrowsPrices[0..<8]) : []
        return todaysPrices + nightsPrices
    }

    func filterInSameDaysAs(_ dates: [Date], using calendar: Calendar = .current) -> [PricePoint] {
        dates.sorted().reduce([]) { partialResult, date in
            return partialResult + filterInSameDay(as: date, using: calendar)
        }
    }

    func filterForViewMode(
        _ viewMode: PriceChartViewMode,
        at date: Date = .now,
        using calendar: Calendar = .current
    ) -> [Element] {
        switch viewMode {
        case .today:
            return filterInSameDay(as: date, using: calendar)
        case .todayAndComingNight:
            return filterInSameDayAndComingNight(as: date, using: calendar)
        case .todayAndTomorrow:
            let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
            return filterInSameDaysAs([date, nextDay], using: calendar)
        case .nowAndUpcoming:
            return filter({ calendar.startOfHour(for: date) <= $0.date })
        }
    }

}

extension Array where Element == PricePoint {
    func shiftDatesToNow() -> [PricePoint] {
        return enumerated().map({ (i, p) in
            let h = TimeInterval(i * 60 * 60)
            return PricePoint(
                date: Calendar.current.startOfDay(for: .now).addingTimeInterval(h),
                price: p.price,
                currency: p.currency
            )
        })
    }
}
