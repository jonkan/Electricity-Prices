//
//  ElectricityPricesWidget.swift
//  Widgets
//
//  Created by Jonas Bromö on 2022-09-18.
//

import WidgetKit
import SwiftUI
import EPWatchCore

struct ElectricityPricesWidget: Widget {
    let kind: String = "Electricity Prices Widget"
    private let state: AppState

    @MainActor
    init() {
        state = .shared
    }

    @MainActor
    init(state: AppState) {
        self.state = state
    }

    var families: [WidgetFamily] {
        #if os(watchOS)
        return [
            .accessoryCircular,
            .accessoryInline,
            .accessoryCorner,
            .accessoryRectangular
        ]
        #else
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ]
        #endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PricePointTimelineProvider(state: state)
        ) { entry in
            WidgetView(entry: entry)
                .unredacted()
        }
        .configurationDisplayName("Electricity price")
        .description("Displays the current electricity price")
        .supportedFamilies(families)
        .contentMarginsDisabled()
    }
}

#Preview(as: .accessoryRectangular) {
    MainActor.assumeIsolated {
        ElectricityPricesWidget(state: .mocked)
    }
} timeline: {
    PricePointTimelineEntry.mock
    PricePointTimelineEntry.mock2
    PricePointTimelineEntry.mockTodayAndComingNight
}

#Preview("Today and Tomorrow", as: .accessoryRectangular) {
    MainActor.assumeIsolated {
        ElectricityPricesWidget(state: .mockedTodayAndTomorrow)
    }
} timeline: {
    PricePointTimelineEntry.mock
    PricePointTimelineEntry.mock2
    PricePointTimelineEntry.mockTodayAndTomorrow
}
