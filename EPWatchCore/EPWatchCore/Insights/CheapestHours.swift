//
//  CheapestHours.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2024-10-18.
//

import Foundation

public struct CheapestHours {
    public let start: Date
    public let duration: Int
    public let price: Double

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

extension AppState {

    public var cheapestHours: CheapestHours {
        let filteredPrices = prices.filterForViewMode(chartViewMode)
            .filter({ Calendar.current.startOfHour(for: .now) <= $0.date })
        return filteredPrices.cheapestHours(for: Int(cheapestHoursDuration))
    }

}

extension Array where Element == PricePoint {

    func cheapestHours(for duration: Int) -> CheapestHours {
        var minCost: Double = .greatestFiniteMagnitude
        var start: Date = .distantPast

        for i in 0...(count - duration) {
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
            price: minCost
        )
    }
}
