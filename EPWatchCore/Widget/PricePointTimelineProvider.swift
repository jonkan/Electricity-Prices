//
//  PricePointTimelineProvider.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import WidgetKit
import Combine
import SwiftUI

public struct PricePointTimelineProvider: TimelineProvider {

    public typealias Entry = PricePointTimelineEntry

    @AppStorage("numberOfFailures")
    var numberOfFailures: Int = 0

    public init() {

    }

    public func placeholder(in context: Context) -> Entry {
        return .mock
    }

    public func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        Task {
            do {
                let state = AppState.shared
                try await state.updatePricesIfNeeded()
                let prices = await state.prices
                let limits = await state.priceLimits
                let currencyPresentation = await state.currencyPresentation
                let chartStyle = await state.chartStyle

                guard let price = prices.price(for: .now) else {
                    throw NSError(0, "Missing current pricePoint")
                }
                let entry = PricePointTimelineEntry(
                    pricePoint: price,
                    prices: prices.filterInSameDayAs(price),
                    limits: limits,
                    currencyPresentation: currencyPresentation,
                    chartStyle: chartStyle
                )
                Log("Provided a timeline snapshot")
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
                let state = AppState.shared
                try await state.updatePricesIfNeeded()
                let allPrices = await state.prices
                let limits = await state.priceLimits
                let currencyPresentation = await state.currencyPresentation
                let chartStyle = await state.chartStyle

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
                                limits: limits,
                                currencyPresentation: currencyPresentation,
                                chartStyle: chartStyle
                            )
                        })
                    )
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                if let start = entries.first?.date, let end = entries.last?.date {
                    Log("Provided \(entries.count) timeline entries from: \(start), to: \(end)")
                } else {
                    Log("Provided no timeline entries")
                }
                numberOfFailures = 0
                completion(timeline)
            } catch {
                LogError("Timeline failure \(numberOfFailures): \(String(describing: error))")
                let delay = retryDelay(for: numberOfFailures)
                numberOfFailures = numberOfFailures + 1
                completion(Timeline(entries: [], policy: .after(.now.addingTimeInterval(delay))))
            }
        }
    }

    // Inspiration https://phelgo.com/exponential-backoff/
    // This produces the delays (without the 0-30s jitter)
    // 0: 30 s
    // 1: 2 min
    // 2: 8 min
    // 3: 32 min
    // 4: 60 min (max delay)
    private func retryDelay(for retry: Int) -> TimeInterval {
        let maxDelay: TimeInterval = 60 * 60
        let delay = 30 * pow(4.0, Double(retry))
        let jitter = 30 * TimeInterval.random(in: 0...1)
        return min(delay + jitter, maxDelay)
    }

}
