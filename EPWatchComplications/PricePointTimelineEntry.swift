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
    var limits: PriceLimits

    var date: Date {
        pricePoint.date
    }

    static var mock = PricePointTimelineEntry(
        pricePoint: .mockPrice,
        limits: PriceLimits(high: 3, low: 1)
    )

    static var mock2 = PricePointTimelineEntry(
        pricePoint: .mockPrice2,
        limits: PriceLimits(high: 3, low: 1)
    )

    static var mock3 = PricePointTimelineEntry(
        pricePoint: .mockPrice3,
        limits: PriceLimits(high: 3, low: 1)
    )
}
