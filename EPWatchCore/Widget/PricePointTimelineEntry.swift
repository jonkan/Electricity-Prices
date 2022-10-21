//
//  PricePointTimelineEntry.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit

public struct PricePointTimelineEntry: TimelineEntry {

    public var pricePoint: PricePoint
    public var prices: [PricePoint]
    public var limits: PriceLimits

    public init(pricePoint: PricePoint, prices: [PricePoint], limits: PriceLimits) {
        self.pricePoint = pricePoint
        self.prices = prices
        self.limits = limits

//        assert(prices.count == prices.filterInSameDayAs(pricePoint).count, "Prices not in the same day as the pricePoint")
    }

    public var date: Date {
        pricePoint.date
    }

    public static let mock = PricePointTimelineEntry(
        pricePoint: .mockPrice,
        prices: .mockPrices,
        limits: .default
    )

    public static let mock2 = PricePointTimelineEntry(
        pricePoint: .mockPrice2,
        prices: .mockPrices,
        limits: PriceLimits(high: 3.2, low: 1.4)
    )

    public static let mock3 = PricePointTimelineEntry(
        pricePoint: .mockPrice3,
        prices: .mockPrices,
        limits: .default
    )
}
