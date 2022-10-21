//
//  Entry.swift
//  EPWatchComplicationsExtension
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit
import EPWatchCore

struct PricePointTimelineEntry: TimelineEntry {
    var pricePoint: PricePoint
    var dayPriceSpan: PriceSpan

    var date: Date {
        pricePoint.date
    }

    static var example: PricePointTimelineEntry {
        PricePointTimelineEntry(
            pricePoint: PricePoint(date: Date(), price: 1.23),
            dayPriceSpan: PriceSpan(date: Date(), min: 1, max: 2)
        )
    }
}
