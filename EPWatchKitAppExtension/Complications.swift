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
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: PricePointTimelineEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            circular
        case .accessoryRectangular:
            rectangular
        case .accessoryCorner:
            corner
        case .accessoryInline:
            inline
        default: circular
        }

    }

    var circular: some View {
        Gauge(value: entry.pricePoint.price, in: entry.pricePoint.dayPriceRange) {
            Text(entry.pricePoint.formattedTimeInterval(.short))
        } currentValueLabel: {
            Text("\(entry.pricePoint.formattedPrice(.short))")
                .padding(1)
        }
        .gaugeStyle(
            CircularGaugeStyle(
                tint: Gradient(
                    stops: entry.limits.stops(using: entry.pricePoint.dayPriceRange)
                )
            )
        )
    }

    var rectangular: some View {
        HStack {
            VStack {
                Text(entry.pricePoint.formattedPrice(.short))
                    .bold()
                Text("Kr")
            }
            PriceChartView(
                currentPrice: entry.pricePoint,
                prices: entry.prices,
                limits: entry.limits
            )
        }
    }

    var corner: some View {
// TODO: Figure out the gradient
//        ZStack {
//            AccessoryWidgetBackground()
//            Text(entry.pricePoint.formattedPrice(.short))
//        }
//        .widgetLabel {
//            Gauge(value: entry.pricePoint.price, in: entry.pricePoint.dayPriceRange) {
//                EmptyView()
//            }
//            .gaugeStyle(.linear)
//            .tint(Gradient(
//                stops: entry.limits.stops(using: entry.pricePoint.dayPriceRange)
//            ))
//        }
        inline
    }

    var inline: some View {
        Text(entry.pricePoint.formattedPrice(.normal))
            .bold()
            .foregroundColor(entry.limits.color(of: entry.pricePoint.price))
    }
}

struct Complication_Previews: PreviewProvider {
    static var previews: some View {
        ComplicationView(entry: .mock3)
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

