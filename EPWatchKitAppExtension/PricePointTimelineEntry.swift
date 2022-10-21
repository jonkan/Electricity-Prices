//
//  PricePointTimelineEntry.swift
//  EPWatchComplicationsExtension
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit
import EPWatchCore

struct PricePointTimelineEntry: TimelineEntry {
    var pricePoint: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits

    init(pricePoint: PricePoint, prices: [PricePoint], limits: PriceLimits) {
        self.pricePoint = pricePoint
        self.prices = prices
        self.limits = limits

//        assert(prices.count == prices.filterInSameDayAs(pricePoint).count, "Prices not in the same day as the pricePoint")
    }

    var date: Date {
        pricePoint.date
    }

    static var mock = PricePointTimelineEntry(
        pricePoint: .mockPrice,
        prices: .mockPrices,
        limits: .default
    )

    static var mock2 = PricePointTimelineEntry(
        pricePoint: .mockPrice2,
        prices: .mockPrices,
        limits: PriceLimits(high: 3.2, low: 1.4)
    )

    static var mock3 = PricePointTimelineEntry(
        pricePoint: .mockPrice3,
        prices: .mockPrices,
        limits: .default
    )
}
