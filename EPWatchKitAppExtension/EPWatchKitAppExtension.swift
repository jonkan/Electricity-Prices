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

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PricePointTimelineProvider()) { entry in
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
    EPWatchKitAppExtension()
} timeline: {
    PricePointTimelineEntry.mock
    PricePointTimelineEntry.mock2
    PricePointTimelineEntry.mock3
}
