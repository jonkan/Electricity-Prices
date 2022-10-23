//
//  PricePointTimelineEntry.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit

public struct PricePointTimelineEntry: TimelineEntry {

    var pricePoint: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits
    var currencyPresentation: CurrencyPresentation

    public init(
        pricePoint: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyPresentation: CurrencyPresentation
    ) {
        self.pricePoint = pricePoint
        self.prices = prices
        self.limits = limits
        self.currencyPresentation = currencyPresentation
    }

    public var date: Date {
        pricePoint.date
    }

    public static let mock = PricePointTimelineEntry(
        pricePoint: .mockPrice,
        prices: .mockPrices,
        limits: .mockLimits,
        currencyPresentation: .natural
    )

    public static let mock2 = PricePointTimelineEntry(
        pricePoint: .mockPrice2,
        prices: .mockPrices,
        limits: PriceLimits(.SEK, high: 3.2, low: 1.4),
        currencyPresentation: .natural
    )

    public static let mock3 = PricePointTimelineEntry(
        pricePoint: .mockPrice3,
        prices: .mockPrices,
        limits: .mockLimits,
        currencyPresentation: .natural
    )
}
