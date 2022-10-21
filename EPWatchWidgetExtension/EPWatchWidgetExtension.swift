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

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PricePointTimelineProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Electricity price")
        .description("Displays the current electricity price")
    }
}

struct EPWatchWidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: .mock2)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
