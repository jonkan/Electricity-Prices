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
    @AppStorage("numberTriesFetchingPricesOfTomorrow")
    var numberTriesFetchingPricesOfTomorrow: Int = 0

    private let state: AppState

    var calendar: Calendar {
        return .current
    }

    public init(state: AppState) {
        self.state = state
    }

    public func placeholder(in context: Context) -> Entry {
        return .mock
    }

    public func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        Task { @MainActor in
            do {
                try await state.updatePricesIfNeeded()
                let cheapestHours = state.showCheapestHours ? state.cheapestHours : nil

                guard let price = state.prices.price(for: .now) else {
                    throw NSError(0, "Missing current pricePoint")
                }
                let prices = state.prices.filterForViewMode(state.chartViewMode, at: price.date, using: calendar)
                let entry = PricePointTimelineEntry(
                    pricePoint: price,
                    prices: prices,
                    limits: state.priceLimits,
                    pricePresentation: state.pricePresentation,
                    chartStyle: state.chartStyle,
                    cheapestHours: cheapestHours
                )
                Log("Provided a timeline snapshot")
                completion(entry)
            } catch {
                LogError(error)
                completion(.mock)
            }
        }
    }

    // swiftlint:disable function_body_length
    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let durationStart = Date()
        Log("Get timeline started")
        Task { @MainActor in
            do {
                try await state.updatePricesIfNeeded()
                let cheapestHours = state.showCheapestHours ? state.cheapestHours : nil

                var entries: [Entry] = []
                let currentHour = calendar.startOfHour(
                    for: isRunningForSnapshots() && use941ForSnapshots() ? .nine41 : .now
                )
                for price in state.prices {
                    guard price.date >= currentHour else {
                        // Skip past timeline entries
                        continue
                    }
                    // Don't provide more than 12 entries, as
                    // somewhere around 24-48 has shown too many.
                    if entries.count >= 12 {
                        break
                    }
                    let prices = state.prices.filterForViewMode(state.chartViewMode, at: price.date, using: calendar)
                    entries.append(
                        PricePointTimelineEntry(
                            pricePoint: price,
                            prices: prices,
                            limits: state.priceLimits,
                            pricePresentation: state.pricePresentation,
                            chartStyle: state.chartStyle,
                            cheapestHours: cheapestHours
                        )
                    )
                }

                // Schedule the next reload depending on wether we have tomorrow's prices already.
                let hasPricesForTomorrow = calendar.isDateInTomorrow(entries.last?.date ?? .distantPast)
                let reloadPolicy: TimelineReloadPolicy
                let reloadDescription: String
                if hasPricesForTomorrow {
                    reloadPolicy = .atEnd
                    reloadDescription = "at end"
                    numberTriesFetchingPricesOfTomorrow = 0
                } else if PricesAPI.shared.dateWhenTomorrowsPricesBecomeAvailable < .now {
                    // swiftlint:disable:next line_length
                    Log("Don't have prices for tomorrow, even though time is after dateWhenTomorrowsPricesBecomeAvailable")
                    let delay = retryDelay(for: numberTriesFetchingPricesOfTomorrow)
                    let nextReload: Date = .now.addingTimeInterval(delay)
                    reloadPolicy = .after(nextReload)
                    reloadDescription = "after \(nextReload)"
                    numberTriesFetchingPricesOfTomorrow += 1
                } else {
                    reloadPolicy = .after(PricesAPI.shared.dateWhenTomorrowsPricesBecomeAvailable)
                    reloadDescription = "after \(PricesAPI.shared.dateWhenTomorrowsPricesBecomeAvailable)"
                    numberTriesFetchingPricesOfTomorrow = 0
                    numberOfFailures = 0
                }

                let timeline = Timeline(entries: entries, policy: reloadPolicy)
                if let start = entries.first?.date, let end = entries.last?.date {
                    assert(start <= end, "The first entry should be dated before the last")
                    Log("Provided \(entries.count) timeline entries from: \(start), to: \(end). Reload policy: \(reloadDescription)")
                } else {
                    Log("Provided no timeline entries")
                }
                numberOfFailures = 0
                completion(timeline)
            } catch {
                LogError("Timeline failure \(numberOfFailures): \(String(describing: error))")
                let delay = retryDelay(for: numberOfFailures)
                numberOfFailures += 1
                completion(Timeline(entries: [], policy: .after(.now.addingTimeInterval(delay))))
            }
            let duration = Date().timeIntervalSince(durationStart).rounded()
            Log("Get timeline end, duration \(duration)s")
        }
    }

    private func retryDelay(for retry: Int) -> TimeInterval {
        let delayInMinutes: Int
        switch retry {
        case 0: delayInMinutes = 10
        case 1: delayInMinutes = 30
        default: delayInMinutes = 60
        }
        // 0-30s jitter
        let jitter = 30 * TimeInterval.random(in: 0...1)
        return Double(delayInMinutes * 60) + jitter
    }

}
