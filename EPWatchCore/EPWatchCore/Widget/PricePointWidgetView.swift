//
//  PricePointWidgetView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import SwiftUI
import WidgetKit

public struct WidgetView: View {

    @Environment(\.widgetFamily) private var widgetFamily

    let entry: PricePointTimelineEntry

    public init(entry: PricePointTimelineEntry) {
        if isRunningForSnapshots() && use941ForSnapshots() {
            self.entry = .init(
                pricePoint: entry.prices.price(for: .nine41)!,
                prices: entry.prices,
                limits: entry.limits,
                pricePresentation: entry.pricePresentation,
                chartStyle: entry.chartStyle,
                cheapestHours: entry.cheapestHours
            )
        } else {
            self.entry = entry
        }
    }

    public var body: some View {
        ZStack {
            switch widgetFamily {
            case .accessoryCircular:
                PricePointCircularWidgetView(entry: entry)
            case .accessoryRectangular:
                PricePointRectangularWidgetView(entry: entry)
            case .accessoryCorner:
                PricePointInlineWidgetView(entry: entry)
            case .accessoryInline:
                PricePointInlineWidgetView(entry: entry)
#if os(iOS)
            case .systemSmall:
                PricePointLargeWidgetView(entry: entry)
            case .systemMedium:
                PricePointLargeWidgetView(entry: entry)
            case .systemLarge:
                PricePointLargeWidgetView(entry: entry)
            case .systemExtraLarge:
                PricePointLargeWidgetView(entry: entry)
#endif
            default:
                PricePointCircularWidgetView(entry: entry)
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

}

#Preview {
    WidgetView(entry: .mock)
}
