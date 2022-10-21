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
    private var prices: [PricePoint]?

    @AppStorageCodable("CurrencyConversion")
    private var cachedForex: ForexLatest?

    private var isUpdatingCurrentPrice: Bool = false

    static let didUpdateDayAheadPrices = Notification.Name("didUpdateDayAheadPrices")

    private init() {
        updateCurrentPrice()
    }

    private var timer: Timer?
    var isTimerRunning: Bool = false {
        didSet {
            if isTimerRunning {
                updateCurrentPrice()
                let nextHour = DateInRegion().dateAtStartOf(.hour) + 1.hours
                timer = Timer(
                    fireAt: nextHour.date,
                    interval: 1.hours.timeInterval,
                    target: self,
                    selector: #selector(updateCurrentPrice),
                    userInfo: nil,
                    repeats: true
                )
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    @objc func updateCurrentPrice() {
        guard !isUpdatingCurrentPrice else { return }
        Task {
            do {
                _ = try await updateCurrentPrice()
            } catch {
                LogError(error)
            }
        }
    }

    @discardableResult
    func updateCurrentPrice() async throws -> PricePoint {
        Log("Update current price begin")
        isUpdatingCurrentPrice = true
        defer { isUpdatingCurrentPrice = false }

        let price = try await getCurrentPrice()
        currentPrice = price
        Log("Update current price success")
        return price
    }

    func allPrices() async throws -> [PricePoint] {
        _ = try await getCurrentPrice()
        return prices ?? []
    }

    private func getCurrentPrice() async throws -> PricePoint {
        if let price = prices?.price(for: Date()) {
            return price
        }
        Log("Downloading day ahead prices")
        let dayAheadPrices = try await PricesAPI.shared.downloadDayAheadPrices()
        let forex = try await currentForex()
        let rate = try forex.rate(from: "EUR", to: "SEK")
        prices = dayAheadPrices.prices(using: rate)
        guard let price = prices?.price(for: Date()) else {
            throw NSError(0, "No price found")
        }
        NotificationCenter.default.post(name: Self.didUpdateDayAheadPrices, object: self)
        return price
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
