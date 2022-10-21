//
//  PriceSpan.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-14.
//

import Foundation

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
