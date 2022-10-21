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

    var priceRange: ClosedRange<Double> {
        entry.dayPriceRange.min...entry.dayPriceRange.max
    }

    var body: some View {
        Gauge(value: entry.pricePoint.price, in: priceRange) {
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
                stops: [
                    .init(color: .green, location: 0.2),
                    .init(color: .yellow, location: 0.4),
                    .init(color: .red, location: 0.8)
                ]
            )
        )
    }
}

struct Complication_Previews: PreviewProvider {
    static var previews: some View {
        ComplicationView(entry: .example)
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

