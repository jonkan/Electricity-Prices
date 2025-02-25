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

// swiftlint:disable type_body_length
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
    public var chartStyle: PriceChartStyle = .bar() {
        didSet {
            guard oldValue != chartStyle else { return }
            Log("Chart presentation did change: \(chartStyle)")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    @AppStorageCodable("ChartViewMode", storage: .appGroup)
    public var chartViewMode: PriceChartViewMode = .todayAndComingNight {
        didSet {
            guard oldValue != chartViewMode else { return }
            Log("Chart view mode did change: \(chartViewMode)")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    @AppStorageCodable("AllPriceLimits", storage: .appGroup)
    public var allPriceLimits: [Currency: PriceLimits] = Currency.defaultPriceLimitsDictionary {
        didSet {
            guard oldValue != allPriceLimits else { return }
            Log("All price limits did change: \(allPriceLimits)")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    public var priceLimits: PriceLimits {
        get { allPriceLimits[currency] ?? currency.defaultPriceLimits }
        set { allPriceLimits[currency] = newValue }
    }

    @AppStorageCodable("ExchangeRates", storage: .appGroup)
    var exchangeRates: [Currency: ExchangeRate] = [:]

    public var exchangeRate: ExchangeRate? {
        exchangeRates[currency]
    }

    // See AppState+Insights.swift
    @AppStorage("CheapestHoursDuration", store: .appGroup)
    public var cheapestHoursDuration: Double = 3 {
        didSet {
            guard oldValue != cheapestHoursDuration else { return }
            Log("Cheapest hours duration did change: \(cheapestHoursDuration)")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    @AppStorage("ShowCheapestHours", store: .appGroup)
    public var showCheapestHours: Bool = false {
        didSet {
            guard oldValue != showCheapestHours else { return }
            Log("Show cheapest hours did change: \(showCheapestHours)")
            objectWillChange.send()
            reloadAllTimelinesSubject.send()
        }
    }

    public var isFetching: Bool {
        updateTask != nil
    }

    public var userPresentableError: UserPresentableError? {
        didSet {
            Log("User presentable error did change: \(userPresentableError?.debugDescription ?? "nil")")
            Task { objectWillChange.send() }
        }
    }

    public var isBadgeVisible: Bool {
        lastVisitedNewsDate < mostRecentNewsDate
    }
    @AppStorageCodable("last-visited-news", storage: .appGroup)
    public var lastVisitedNewsDate: Date = .distantPast
    private let mostRecentNewsDate: Date = ISO8601DateFormatter()
        .date(from: "2025-02-20T12:00:00Z")!

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

        if region == nil || isRunningForSnapshots() {
            if let currentRegion = Region.current {
                region = currentRegion
                priceArea = currentRegion.priceAreas.first
            } else {
                region = .sweden
                priceArea = Region.sweden.priceAreas[2]
            }
        }
        if priceArea == nil {
            priceArea = region?.priceAreas.first
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

        if isRunningForSnapshots() {
            // Mocked prices are set in downloadPrices()
            chartStyle = .bar()
            chartViewMode = .today
            currency = Region.current?.suggestedCurrency ?? .EUR
            exchangeRates[currency] = .mockedEUR(to: currency)
            currencyPresentation = .automatic
            invalidateAndUpdatePrices()
        } else if !isSwiftUIPreview() {
            updatePricesIfNeeded()
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

    // swiftlint:disable:next function_body_length
    public func updatePricesIfNeeded() async throws {
        guard !isSwiftUIPreview() else {
            return
        }
        guard !isRunningForSnapshots() else {
            prices = try await mockedPrices()
            currentPrice = prices.price(for: use941ForSnapshots() ? .nine41 : .now)
            return
        }
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
            let tomorrowsPricesShouldBeAvailable = EntsoePricesAPI.shared.dateWhenTomorrowsPricesBecomeAvailable < .now
            let timeIntervalSinceLastFetchAttempt = Date.now.timeIntervalSince(
                lastAttemptFetchingTomorrowsPrices ?? .distantPast
            )
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
            if currentPrice == nil {
                throw UserPresentableError.noCurrentPrice
            } else {
                Log("Success updating prices")
            }
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
        async let dayAheadPrices = try EntsoePricesAPI.shared.downloadDayAheadPrices(for: priceArea)
        async let rate = try currentExchangeRate()
        let prices = try await dayAheadPrices.prices(using: rate)
        return prices
    }

    private func mockedPrices() async throws -> [PricePoint] {
        let dayAheadPrices = EntsoeDayAheadPrices.mocked1
        assert(exchangeRate?.to == currency, "Missing preset exhange rate for currency \(currency.id)")
        let prices = try dayAheadPrices.prices(using: exchangeRate!).shiftDatesToNow()
        return prices
    }

    public func currentExchangeRate() async throws -> ExchangeRate {
        if let exchangeRate = exchangeRate,
           exchangeRate.isUpToDate(),
           exchangeRate.from == .EUR,
           exchangeRate.to == currency {
            return exchangeRate
        }
        Log("Downloading exchange rate")
        do {
            let res = try await ForexAPI.shared.download(from: .EUR, to: currency)
            Log("Success downloading exchange rate")
            exchangeRates[res.to] = res
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
