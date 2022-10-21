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

@MainActor
public class AppState: ObservableObject {

    public static let shared: AppState = AppState()
    @Published public var currentPrice: PricePoint?
    @Published public var todaysPriceSpan: PriceSpan?

    @AppStorageCodable("prices")
    public var prices: [PricePoint]?

    public var todaysPrices: [PricePoint] {
        prices?.filter({ $0.date.isToday }) ?? []
    }

    @AppStorageCodable("CurrencyConversion")
    private var cachedForex: ForexLatest?

    private var isUpdating: Bool = false

    nonisolated
    public static let didUpdateDayAheadPrices = Notification.Name("didUpdateDayAheadPrices")

    private init() {
        updatePricesIfNeeded()
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
                timer?.fire()
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    @objc
    public func updatePricesIfNeeded() {
        Task {
            do {
                _ = try await updatePricesIfNeeded()
            } catch {
                LogError(error)
            }
        }
    }

    public func updatePricesIfNeeded() async throws {
        if let price = prices?.price(for: Date()) {
            if price != currentPrice {
                currentPrice = price
                todaysPriceSpan = prices?.priceSpan(forDayOf: Date())
            }
            return
        }
//        guard !isUpdating else { return }
        Log("Update current price begin")
//        isUpdating = true
//        defer { isUpdating = false }
        do {
            prices = try await getTodaysPrices()
            currentPrice = prices?.price(for: Date())
            todaysPriceSpan = prices?.priceSpan(forDayOf: Date())
            Log("Update current price success")
            NotificationCenter.default.post(name: Self.didUpdateDayAheadPrices, object: self)
        } catch {
            currentPrice = nil
            todaysPriceSpan = nil
            throw error
        }
    }

    private func getTodaysPrices() async throws -> [PricePoint] {
        Log("Downloading day ahead prices")
        let dayAheadPrices = try await PricesAPI.shared.downloadDayAheadPrices()
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
