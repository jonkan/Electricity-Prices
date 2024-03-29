//
//  EPWatchKitAppExtension.swift
//  EPWatchKitAppExtension
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit
import SwiftUI
import EPWatchCore

@main
struct EPWatchKitAppExtension: Widget {
    let kind: String = "EPWatchKitAppExtension"
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
                .accessoryCircular,
                .accessoryInline,
                .accessoryCorner,
                .accessoryRectangular
            ]
        )
        .contentMarginsDisabled()
    }
}

#Preview(as: .accessoryRectangular) {
    MainActor.assumeIsolated {
        EPWatchKitAppExtension(state: .mocked)
    }
} timeline: {
    PricePointTimelineEntry.mock
    PricePointTimelineEntry.mock2
    PricePointTimelineEntry.mock3
}
