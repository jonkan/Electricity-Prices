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
            if let region = region {
                // Reset the priceArea if the selected doesn't exist in the region
                if !region.priceAreas.contains(where: { $0.id == priceArea?.id }) {
                    priceArea = region.priceAreas.first
                }
                currency = region.suggestedCurrency
            }
            invalidateAndUpdatePricesSubject.send()
        }
    }

    @AppStorageCodable("PriceArea", storage: .appGroup)
    public var priceArea: PriceArea? = nil {
        didSet {
            guard oldValue != priceArea else { return }
            Log("Price area did change: \(priceArea?.title ?? "nil")")
            invalidateAndUpdatePricesSubject.send()
        }
    }

    /// The currently selected currency
    @AppStorageCodable("Currency", storage: .appGroup)
    public var currency: Currency = .EUR {
        didSet {
            guard oldValue != currency else { return }
            Log("Currency did change: \(currency.name)")
            pricePresentation.currencyPresentation = currency.suggestedCurrencyPresentation
            invalidateAndUpdatePricesSubject.send()
        }
    }

    @AppStorageCodable("CurrencyPresentation", storage: .appGroup)
    private var currencyPresentation: CurrencyPresentation = .subdivided

    @AppStorageCodable("PricePresentation", storage: .appGroup)
    public var pricePresentation: PricePresentation = .init() {
        didSet {
            guard oldValue != pricePresentation else { return }
            Log("Price presentation did change")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    @AppStorageCodable("ChartStyle", storage: .appGroup)
    public var chartStyle: PriceChartStyle = .lineInterpolated {
        didSet {
            guard oldValue != chartStyle else { return }
            Log("Chart presentation did change: \(chartStyle)")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    @AppStorageCodable("AllPriceLimits", storage: .appGroup)
    public var allPriceLimits: [PriceLimits] = [
        PriceLimits(.EUR, high: 0.3, low: 0.1),
        PriceLimits(.SEK, high: 3, low: 1),
        PriceLimits(.NOK, high: 3, low: 1),
        PriceLimits(.DKK, high: 2, low: 0.7),
    ]
    public var priceLimits: PriceLimits {
        return allPriceLimits.first(where: { $0.currency == currency })!
    }

    @AppStorageCodable("ExchangeRate", storage: .appGroup)
    public var exchangeRate: ExchangeRate? = nil

    public var isFetching: Bool {
        updateTask != nil
    }

    public var userPresentableError: UserPresentableError? {
        didSet {
            Log("User presentable error did change: \(userPresentableError?.debugDescription ?? "nil")")
            Task { objectWillChange.send() }
        }
    }

    private var invalidateAndUpdatePricesSubject = PassthroughSubject<Void, Never>()
    private var invalidateAndUpdatePricesCancellable: AnyCancellable?
    private var reloadAllTimelinesSubject = PassthroughSubject<Void, Never>()
    private var reloadAllTimelinesCancellable: AnyCancellable?

    @AppStorageCodable("LastAttemptFetchingTomorrowsPrices", storage: .appGroup)
    private var lastAttemptFetchingTomorrowsPrices: Date? = nil

    @AppStorage("LastUpgradeCheck")
    private var lastUpgradeCheck: String = "1.0"

    private var updateTask: Task<Void, Error>? {
        didSet {
            objectWillChange.send()
        }
    }

    private init() {
        Log("App version: \(AppInfo.version) (\(AppInfo.build)), \(AppInfo.commit)")
        Log("System version: \(AppInfo.systemVersion)")

        updatePricesIfNeeded()

        if region == nil {
            let currentRegionId = Locale.current.region?.identifier
            if let r = Region.allEnabled.first(where: { $0.id == currentRegionId }) {
                region = r
                priceArea = r.priceAreas.first
            } else {
                region = .sweden
                priceArea = Region.sweden.priceAreas[2]
            }
        }

        invalidateAndUpdatePricesCancellable = invalidateAndUpdatePricesSubject
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.invalidateAndUpdatePrices()
            }

        reloadAllTimelinesCancellable = reloadAllTimelinesSubject
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.reloadAllTimelines()
            }

        // Upgrade if coming from an app older than 1.10
        if lastUpgradeCheck.compare("1.10", options: .numeric) == .orderedAscending {
            pricePresentation.currencyPresentation = currencyPresentation
            lastUpgradeCheck = AppInfo.version
        }
    }

    private var timer: Timer?
    public var isTimerRunning: Bool = false {
        didSet {
            if isTimerRunning {
                let startOfHour = Calendar.current.startOfHour(for: .now)
                let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: startOfHour)!
                timer = Timer(
                    fireAt: nextHour,
                    interval: 60 * 60,
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

    private func invalidateAndUpdatePrices() {
        guard !isSwiftUIPreview() else {
            return
        }
        Task {
            prices = []
            currentPrice = nil
            objectWillChange.send()
            do {
                _ = try await updatePricesIfNeeded()
            } catch let presentable as UserPresentableError {
                userPresentableError = presentable
            } catch {
                LogError(error)
                userPresentableError = .unknown(error)
            }
            objectWillChange.send()
            reloadAllTimelines()
        }
    }

    @objc
    public func updatePricesIfNeeded(completion: (() -> Void)? = nil) {
        Task {
            do {
                _ = try await updatePricesIfNeeded()
            } catch let presentable as UserPresentableError {
                userPresentableError = presentable
            } catch {
                LogError(error)
                userPresentableError = .unknown(error)
            }
            completion?()
        }
    }

    public func updatePricesIfNeeded() async throws {
        guard priceArea != nil else {
            Log("No price area set yet")
            currentPrice = nil
            return
        }
        // The updateTask is a hack to make sure we
        // only run one update at a time, so we can
        // await an already running task before launching
        // a new one, if needed.
        // Since we're only waiting, we ignore any thrown error.
        _ = await updateTask?.result
        updateTask = nil

        if let price = prices.price(for: .now),
           price.currency == currency {
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
            // an attempt at updating provided it should be available and we haven't
            // tried recently (within 5 min).
            let tomorrowsPricesShouldBeAvailable = PricesAPI.shared.dateWhenTomorrowsPricesBecomeAvailable < .now
            let timeIntervalSinceLastFetchAttempt = Date.now.timeIntervalSince(lastAttemptFetchingTomorrowsPrices ?? .distantPast)
            if !tomorrowsPricesShouldBeAvailable {
                Log("Update not needed, skip trying to fetch for tomorrow. Tomorrows prices not yet available.")
                return
            } else if timeIntervalSinceLastFetchAttempt < (5 * 60) {
                Log("Update not needed, skip trying to fetch for tomorrow. Already tried fetching at \(lastAttemptFetchingTomorrowsPrices ?? .distantPast).")
                return
            } else {
                Log("Update not needed, but will try to fetch for tomorrow.")
            }
        } else {
            currentPrice = nil
        }
        lastAttemptFetchingTomorrowsPrices = .now

        updateTask = Task {
            Log("Begin updating prices")
            prices = try await downloadPrices()
            currentPrice = prices.price(for: .now)
            Log("Success updating prices")
            objectWillChange.send()
            reloadAllTimelines()
        }
        defer {
            updateTask = nil
        }
        _ = try await updateTask?.value
    }

    private func downloadPrices() async throws -> [PricePoint] {
        guard let priceArea = priceArea else {
            throw NSError(0, "No price area selected")
        }
        async let dayAheadPrices = try PricesAPI.shared.downloadDayAheadPrices(for: priceArea)
        async let rate = try currentExchangeRate()
        let prices = try await dayAheadPrices.prices(using: rate)
#if DEBUG
        if ProcessInfo.processInfo.environment["SHOW_MOCKED_PRICES"] == "true" {
            return .mockPrices
        }
#endif
        return prices
    }

    public func currentExchangeRate() async throws -> ExchangeRate {
        if let exchangeRate = exchangeRate,
           exchangeRate.isUpToDate,
           exchangeRate.from == .EUR,
           exchangeRate.to == currency {
            return exchangeRate
        }
        Log("Downloading exchange rate")
        do {
            let res = try await ForexAPI.shared.download(from: .EUR, to: currency)
            Log("Success downloading exchange rate")
            exchangeRate = res
            return res
        } catch {
            throw UserPresentableError.noExchangeRate(error)
        }
    }

    private func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
        Log("Reloading all timelines")
    }

}

extension AppState {
    public static let mocked: AppState = {
        let s = AppState()
        s.currentPrice = .mockPrice
        s.region = .sweden
        s.priceArea = Region.sweden.priceAreas.first
        s.prices = .mockPrices
        s.exchangeRate = .mockedSEK
        return s
    }()

    public static let mockedWithError: AppState = {
        let s = AppState()
        s.currentPrice = nil
        s.region = .sweden
        s.priceArea = Region.sweden.priceAreas.first
        s.userPresentableError = .noData
        return s
    }()
}
