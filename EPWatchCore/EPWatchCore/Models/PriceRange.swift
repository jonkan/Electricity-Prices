//
//  PriceRange.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-14.
//

import Foundation

public extension Array where Element == PricePoint {
    func priceRange() -> ClosedRange<Double>? {
        guard let max = map({ $0.price }).max(),
              let min = map({$0.price }).min() else {
            return nil
        }
        return min...max
    }

    func priceRange(forDayOf date: Date) -> ClosedRange<Double>? {
        let prices = filter({
            Calendar.current.isDate($0.date, inSameDayAs: date)
        })
        return prices.priceRange()
    }
}
