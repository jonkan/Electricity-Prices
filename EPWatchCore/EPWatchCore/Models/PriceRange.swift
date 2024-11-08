//
//  PriceRange.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-14.
//

import Foundation

public struct PriceRange {
    public let max: Double
    public let min: Double
    public let mean: Double

    static let zero = PriceRange(max: 0, min: 0, mean: 0)
}

public extension Array where Element == PricePoint {
    func priceRange() -> PriceRange? {
        let prices = map({ $0.price })
        guard let max = prices.max(), let min = prices.min() else {
            return nil
        }
        return PriceRange(max: max, min: min, mean: prices.reduce(0, +) / Double(prices.count))
    }

    func priceRange(forDayOf date: Date) -> PriceRange? {
        let prices = filter({
            Calendar.current.isDate($0.date, inSameDayAs: date)
        })
        return prices.priceRange()
    }
}
