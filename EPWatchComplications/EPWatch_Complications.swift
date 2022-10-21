//
//  EPWatch_Complications.swift
//  EPWatch Complications
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit
import SwiftUI
import EPWatchCore

extension PricePoint: TimelineEntry {}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PricePoint {
        PricePoint(date: Date(), price: 1.23)
    }

    func getSnapshot(in context: Context, completion: @escaping (PricePoint) -> ()) {
        
        let entry = PricePoint(date: Date(), price: 1.23)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PricePoint] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = PricePoint(date: entryDate, price: 1.23)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct EPWatch_ComplicationsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct EPWatch_Complications: Widget {
    let kind: String = "EPWatch_Complications"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EPWatch_ComplicationsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct EPWatch_Complications_Previews: PreviewProvider {
    static var previews: some View {
        EPWatch_ComplicationsEntryView(entry: PricePoint(date: Date(), price: 1.23))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
