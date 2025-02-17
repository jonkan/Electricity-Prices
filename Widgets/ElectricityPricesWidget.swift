//
//  ElectricityPricesWidget.swift
//  Widgets
//
//  Created by Jonas Bromö on 2022-09-18.
//

import WidgetKit
import SwiftUI
import Core

struct ElectricityPricesWidget: Widget {
#if os(watchOS)
    let kind: String = "EPWatchKitAppExtension"
#else
    let kind: String = "EPWatchWidgetExtension"
#endif
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
        .configurationDisplayName(AppInfo.bundleDisplayName)
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

#Preview("Now and Ahead", as: .accessoryRectangular) {
    MainActor.assumeIsolated {
        ElectricityPricesWidget(state: .mockedNowAndAllAhead)
    }
} timeline: {
    PricePointTimelineEntry.mockedNowAndAllAhead1
    PricePointTimelineEntry.mockedNowAndAllAhead2
}
