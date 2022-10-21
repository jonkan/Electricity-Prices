//
//  EPWatch_Complications.swift
//  EPWatch Complications
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit
import SwiftUI
import EPWatchCore
import Combine

struct ComplicationView : View {
    @Environment(\.widgetRenderingMode) private var renderingMode
    var entry: PricePointTimelineEntry

    var body: some View {
        Gauge(value: entry.pricePoint.price, in: entry.pricePoint.dayPriceRange) {
            Text(entry.pricePoint.formattedTimeInterval(.short))
        } currentValueLabel: {
            Text("\(entry.pricePoint.formattedPrice(.short))")
                .padding(1)
        }
        .gaugeStyle(gaugeStyle)
    }

    var gaugeStyle: some GaugeStyle {
        CircularGaugeStyle(
            tint: Gradient(
                stops: entry.limits.stops(using: entry.pricePoint.dayPriceRange)
            )
        )
    }
}

struct Complication_Previews: PreviewProvider {
    static var previews: some View {
        ComplicationView(entry: .mock2)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}

@main
struct Complications: Widget {
    let kind: String = "EPWatch_Complications"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationView(entry: entry)
        }
        .configurationDisplayName("Electricity price")
        .description("Displays the current electricity price")
    }
}

