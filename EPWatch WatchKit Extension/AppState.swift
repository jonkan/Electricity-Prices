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
class AppState: ObservableObject {

    static let shared: AppState = AppState()
    @Published var currentPrice: PricePoint?

    @AppStorageCodable("prices")
    var prices: [PricePoint]?

    var todaysPrices: [PricePoint] {
        prices?.filter({ $0.start.isToday }) ?? []
    }

    @AppStorageCodable("CurrencyConversion")
    private var cachedForex: ForexLatest?

    private var isUpdating: Bool = false

    static let didUpdateDayAheadPrices = Notification.Name("didUpdateDayAheadPrices")

    private init() {
        updatePricesIfNeeded()
    }

    private var timer: Timer?
    var isTimerRunning: Bool = false {
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

    @objc func updatePricesIfNeeded() {
        Task {
            do {
                _ = try await updatePricesIfNeeded()
            } catch {
                LogError(error)
            }
        }
    }

    func updatePricesIfNeeded() async throws {
        if let price = prices?.price(for: Date()), price != currentPrice {
            currentPrice = price
            return
        }
        guard !isUpdating else { return }
        Log("Update current price begin")
        isUpdating = true
        defer { isUpdating = false }

        prices = try await getTodaysPrices()
        currentPrice = prices?.price(for: Date())
        Log("Update current price success")
        NotificationCenter.default.post(name: Self.didUpdateDayAheadPrices, object: self)
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
