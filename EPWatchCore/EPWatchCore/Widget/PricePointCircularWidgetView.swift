//
//  PricePointCircularWidgetView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import SwiftUI

public struct PricePointCircularWidgetView: View {

    let entry: PricePointTimelineEntry

    public init(entry: PricePointTimelineEntry) {
        self.entry = entry
    }

    public var body: some View {
        Gauge(value: entry.pricePoint.price, in: entry.pricePoint.dayPriceRange) {
            Text(entry.formattedDateTimeInterval(style: .short))
                .padding(1)
        } currentValueLabel: {
            Text(entry.formattedPrice(style: .short))
                .padding(1)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(Gradient(stops: entry.limits.stops(using: entry.pricePoint.dayPriceRange)))
    }

}

struct PricePointCircularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PricePointCircularWidgetView(entry: .mock)
    }
}

