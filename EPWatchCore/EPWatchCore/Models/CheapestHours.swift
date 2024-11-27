//
//  CheapestHours.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2024-10-18.
//

import Foundation

public struct CheapestHours: FormattablePrice {

    public let start: Date
    public let duration: Int
    public let price: Double
    public let currency: Currency

    /// The end of the last price point.
    public var end: Date {
        priceDates.last!.addingTimeInterval(3600)
    }

    var priceDates: [Date] {
        (0..<duration).map({ start.addingTimeInterval(Double($0) * 3600) })
    }

    func includes(_ pricePoint: PricePoint) -> Bool {
        start <= pricePoint.date && pricePoint.date < end
    }

}

public extension Array where Element == PricePoint {

    func cheapestHours(for duration: Int) -> CheapestHours? {
        guard count > 0 else {
            return nil
        }

        var minCost: Double = .greatestFiniteMagnitude
        var start: Date = .distantPast
        let duration = Swift.max(1, Swift.min(duration, count))
        let length = Swift.max(0, count - duration)

        for i in 0...length {
            let cost = (0..<duration)
                .map { self[i + $0].price }
                .reduce(0, +)
            let date = self[i].date
            if cost < minCost {
                minCost = cost
                start = date
            }
        }

        return CheapestHours(
            start: start,
            duration: duration,
            price: minCost / Double(duration),
            currency: self[0].currency
        )
    }

}
