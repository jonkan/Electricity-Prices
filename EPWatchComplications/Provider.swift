//
//  Provider.swift
//  EPWatchComplicationsExtension
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit
import SwiftUI
import EPWatchCore
import Combine

struct Provider: TimelineProvider {
    var didUpdateDayAheadPricesCancellable: AnyCancellable?

    init() {
        didUpdateDayAheadPricesCancellable = NotificationCenter.default
            .publisher(for: AppState.didUpdateDayAheadPrices)
            .sink { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
    }

    func placeholder(in context: Context) -> PricePointTimelineEntry {
        return .example
    }

    func getSnapshot(in context: Context, completion: @escaping (PricePointTimelineEntry) -> ()) {
        Task {
            do {
                try await AppState.shared.updatePricesIfNeeded()
                guard let prices = await AppState.shared.prices else {
                    throw NSError(0, "Unable to retrieve prices")
                }
                guard let price = prices.price(for: Date()) else {
                    throw NSError(0, "Missing current pricePoint")
                }
                guard let priceSpan = prices.priceSpan(forDayOf: Date()) else {
                    throw NSError(0, "No price span")
                }
                let entry = PricePointTimelineEntry(
                    pricePoint: price,
                    dayPriceSpan: priceSpan
                )
                completion(entry)
            } catch {
                LogError(error)
                completion(.example)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PricePointTimelineEntry>) -> ()) {
        Task {
            do {
                try await AppState.shared.updatePricesIfNeeded()
                guard let allPrices = await AppState.shared.prices else {
                    throw NSError(0, "Unable to retrieve current prices")
                }
                let grouped = Dictionary(
                    grouping: allPrices,
                    by: { $0.date.dateAtStartOf(.day) }
                )
                var entries: [PricePointTimelineEntry] = []
                for (startOfDay, prices) in grouped {
                    guard startOfDay.isToday || startOfDay.isInFuture else {
                        continue
                    }
                    guard let span = prices.priceSpan(forDayOf: startOfDay) else {
                        LogError("Failed to calculate price span of \(prices.count) prices")
                        continue
                    }
                    entries.append(
                        contentsOf: prices.map({
                            PricePointTimelineEntry(
                                pricePoint: $0,
                                dayPriceSpan: span
                            )
                        })
                    )
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            } catch {
                LogError(error)
                completion(Timeline(entries: [], policy: .never))
            }
        }
    }

}
