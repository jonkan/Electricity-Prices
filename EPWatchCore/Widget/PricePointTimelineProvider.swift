//
//  PricePointTimelineProvider.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import WidgetKit
import Combine

public struct PricePointTimelineProvider: TimelineProvider {

    public typealias Entry = PricePointTimelineEntry
    var didUpdateDayAheadPricesCancellable: AnyCancellable?

    public init() {
        didUpdateDayAheadPricesCancellable = NotificationCenter.default
            .publisher(for: AppState.didUpdateDayAheadPrices)
            .sink { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
    }

    public func placeholder(in context: Context) -> Entry {
        return .mock
    }

    public func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        Task {
            do {
                try await AppState.shared.updatePricesIfNeeded()
                let prices = await AppState.shared.prices
                let limits = await AppState.shared.priceLimits

                guard let price = prices.price(for: .now) else {
                    throw NSError(0, "Missing current pricePoint")
                }
                let entry = PricePointTimelineEntry(
                    pricePoint: price,
                    prices: prices.filterInSameDayAs(price),
                    limits: limits
                )
                completion(entry)
            } catch {
                LogError(error)
                completion(.mock)
            }
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                try await AppState.shared.updatePricesIfNeeded()
                let allPrices = await AppState.shared.prices
                let limits = await AppState.shared.priceLimits

                let grouped = Dictionary(
                    grouping: allPrices,
                    by: { Calendar.current.startOfDay(for: $0.date) }
                )
                var entries: [Entry] = []
                for (startOfDay, prices) in grouped {
                    guard Calendar.current.isDateInToday(startOfDay) || .now < startOfDay else {
                        continue
                    }
                    entries.append(
                        contentsOf: prices.map({
                            PricePointTimelineEntry(
                                pricePoint: $0,
                                prices: prices,
                                limits: limits
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
