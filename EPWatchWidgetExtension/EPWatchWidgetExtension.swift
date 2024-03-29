//
//  EPWatchWidgetExtension.swift
//  EPWatchWidgetExtension
//
//  Created by Jonas Bromö on 2022-09-18.
//

import WidgetKit
import SwiftUI
import EPWatchCore

@main
struct EPWatchWidgetExtension: Widget {
    let kind: String = "EPWatchWidgetExtension"
    private let state: AppState

    @MainActor
    init() {
        state = .shared
    }

    @MainActor
    init(state: AppState) {
        self.state = state
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PricePointTimelineProvider(state: state)) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Electricity price")
        .description("Displays the current electricity price")
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular
            ]
        )
        .contentMarginsDisabled()
    }
}

#Preview(as: .accessoryRectangular) {
    MainActor.assumeIsolated {
        EPWatchWidgetExtension(state: .mocked)
    }
} timeline: {
    PricePointTimelineEntry.mock
    PricePointTimelineEntry.mock2
    PricePointTimelineEntry.mock3
}
