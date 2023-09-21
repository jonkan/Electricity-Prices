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
        self.entry = entry
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
        .widgetBackground(backgroundView: Color.clear)
    }

}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
#if os(watchOS)
        WidgetView(entry: .mock)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
#else
        WidgetView(entry: .mock)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
#endif
    }
}
