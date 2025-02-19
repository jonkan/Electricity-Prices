//
//  PricePointCircularWidgetView.swift
//  Core
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
        let closedRange = entry.priceRange.min...entry.priceRange.max
        Gauge(value: entry.pricePoint.price, in: closedRange) {
            DateIntervalText(entry.date, style: .short)
                .minimumScaleFactor(0.5)
                .padding(1)
        } currentValueLabel: {
            Text(entry.formattedPrice(style: .short))
                .minimumScaleFactor(0.5)
                .padding(1)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(Gradient(stops: entry.limits.stops(using: entry.priceRange)))
    }

}

struct PricePointCircularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PricePointCircularWidgetView(entry: .mocked)
    }
}
