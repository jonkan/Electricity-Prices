//
//  AppState.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import SwiftDate
import WidgetKit

@MainActor
public class AppState: ObservableObject {

    public static let shared: AppState = AppState()
    @Published public var currentPrice: PricePoint?

    @AppStorageCodable("prices", storage: .appGroup)
    public var prices: [PricePoint] = []

    @AppStorageCodable("Region", storage: .appGroup)
    public var region: Region? = nil {
        didSet {
            guard oldValue != region else { return }
            Log("Region did change: \(region?.name ?? "nil")")
            if region?.priceAreas.contains(where: { $0.id == priceArea?.id }) == false {
                priceArea = region?.priceAreas.first
            }
            invalidateAndUpdatePrices()
        }
    }

    @AppStorageCodable("PriceArea", storage: .appGroup)
    public var priceArea: PriceArea? = nil {
        didSet {
            guard oldValue != priceArea else { return }
            Log("Price area did change: \(priceArea?.title ?? "nil")")
            invalidateAndUpdatePrices()
        }
    }

    @AppStorageCodable("PriceLimits", storage: .appGroup)
    public var priceLimits: PriceLimits = .default

    @AppStorageCodable("CurrencyConversion", storage: .appGroup)
    private var cachedForex: ForexLatest? = nil

    @AppStorageCodable("LastAttemptFetchingTomorrowsPrices", storage: .appGroup)
    private var lastAttemptFetchingTomorrowsPrices: Date? = nil

    private var updateTask: Task<Void, Never>?

    nonisolated
    public static let didUpdateDayAheadPrices = Notification.Name("didUpdateDayAheadPrices")

    private init() {
        updatePricesIfNeeded()

        if region == nil {
            let currentRegionId = Locale.current.region?.identifier
            if let r = Region.allCases.first(where: { $0.id == currentRegionId }) {
                region = r
                priceArea = r.priceAreas.first
            } else {
                region = .sweden
                priceArea = Region.sweden.priceAreas[2]
            }
        }
    }

    private var timer: Timer?
    public var isTimerRunning: Bool = false {
        didSet {
            if isTimerRunning {
                let nextHour = DateInRegion().dateAtStartOf(.hour) + 1.hours
                timer = Timer(
                    fireAt: nextHour.date,
                    interval: 1.hours.timeInterval,
                    target: self,
                    selector: #selector(updatePricesIfNeeded),
                    userInfo: nil,
                    repeats: true
                )
                updatePricesIfNeeded()
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    func invalidateAndUpdatePrices() {
        prices = []
        currentPrice = nil
        updatePricesIfNeeded {
            WidgetCenter.shared.reloadAllTimelines()
            self.objectWillChange.send()
        }
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    @objc
    public func updatePricesIfNeeded(completion: (() -> Void)? = nil) {
        Task {
            do {
                _ = try await updatePricesIfNeeded()
            } catch {
                LogError(error)
            }
            completion?()
        }
    }

    public func updatePricesIfNeeded() async throws {
        guard priceArea != nil else {
            Log("No price area set yet")
            return
        }
        _ = await updateTask?.result

        if let price = prices.price(for: .now) {
            if price != currentPrice {
                currentPrice = price
            }

            let endOfToday = Calendar.current.endOfDay(for: .now)
            let hasPricesForTomorrow = endOfToday < (prices.last?.date ?? .distantPast)
            if hasPricesForTomorrow {
                Log("Update not needed, has prices for tomorrow")
                return
            }

            // If we have the current price but lack tomorrow's prices we make
            // an attempt at updating provided it's after 13:00 and we haven't
            // tried recently (within 30 min).
            let currentHour = Calendar.current.component(.hour, from: .now)
            let timeIntervalSinceLastFetchAttempt = Date.now.timeIntervalSince(lastAttemptFetchingTomorrowsPrices ?? .distantPast)
            if currentHour < 13 || timeIntervalSinceLastFetchAttempt < (30 * 60) {
                Log("Update not needed, skip trying to fetch for tomorrow")
                return
            }
            Log("Update not needed, but will try to fetch for tomorrow")
        }
        lastAttemptFetchingTomorrowsPrices = .now

        updateTask = Task {
            Log("Begin updating prices")
            do {
                prices = try await downloadPrices()
                currentPrice = prices.price(for: .now)
                Log("Success updating prices")
                NotificationCenter.default.post(name: Self.didUpdateDayAheadPrices, object: self)
            } catch {
                LogError(error)
                currentPrice = nil
            }
        }
        _ = await updateTask?.result
    }

    private func downloadPrices() async throws -> [PricePoint] {
        Log("Downloading day ahead prices")
        guard let priceArea = priceArea else {
            throw NSError(0, "No price area selected")
        }
        let dayAheadPrices = try await PricesAPI.shared.downloadDayAheadPrices(for: priceArea)
        let forex = try await currentForex()
        let rate = try forex.rate(from: "EUR", to: "SEK")
        let prices = dayAheadPrices.prices(using: rate)
        return prices
    }

    private func currentForex() async throws -> ForexLatest {
        if let forex = cachedForex, forex.isUpToDate {
            return forex
        }
        Log("Downloading forex")
        let res = try await ForexAPI.shared.download()
        cachedForex = res
        return res
    }

}

extension AppState {
    public static let mocked: AppState = {
        let s = AppState()
        s.currentPrice = .mockPrice
        s.prices = .mockPrices
        return s
    }()
}
