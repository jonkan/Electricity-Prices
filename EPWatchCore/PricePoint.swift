//
//  PricePoint.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import SwiftDate

public struct PricePoint: Codable, Equatable {
    public var date: Date // And 1h forward
    public var price: Double
    public var dayPriceSpan: ClosedRange<Double>?

    public init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }

    public func formattedPrice(_ style: FormattingStyle) -> String {
        return PriceFormatter.formatted(price, style: style)
    }

    public func formattedTimeInterval(_ style: FormattingStyle) -> String {
        return DateIntervalFormatter.formatted(
            from: date.convertTo(region: .current),
            to: date.convertTo(region: .current).dateByAdding(1, .hour),
            style: style
        )
    }
}

public struct PriceSpan {
    public var date: Date
    public var min: Double
    public var max: Double

    public init(date: Date, min: Double, max: Double) {
        self.date = date
        self.min = min
        self.max = max
    }

    public func formattedMin(style: FormattingStyle) -> String {
        return PriceFormatter.formatted(min, style: style)
    }

    public func formattedMax(style: FormattingStyle) -> String {
        return PriceFormatter.formatted(max, style: style)
    }
}

public extension Array where Element == PricePoint {
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

    func priceSpans() -> [PriceSpan] {
        let groupedByDay = Dictionary(
            grouping: self,
            by: { $0.date.dateAtStartOf(.day) }
        )
        let spans = groupedByDay.map { (key, prices) in
            let max = prices.map({ $0.price }).max() ?? 0
            let min = prices.map({$0.price }).min() ?? 0
            return PriceSpan(date: key, min: min, max: max)
        }
        return spans
    }

    func priceSpan(forDayOf date: Date) -> PriceSpan? {
        let prices = filter({
            Calendar.current.isDate($0.date, inSameDayAs: date)
        })
        let max = prices.map({ $0.price }).max() ?? 0
        let min = prices.map({$0.price }).min() ?? 0
        return PriceSpan(
            date: date.dateAtStartOf(.day),
            min: min,
            max: max
        )
    }
}
