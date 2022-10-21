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

    @AppStorageCodable("prices")
    public var prices: [PricePoint] = []

    @AppStorageCodable("Region")
    public var region: Region = .sweden

    @AppStorageCodable("PriceArea")
    public var priceArea: PriceArea = Region.sweden.priceAreas[2] {
        didSet {
            guard oldValue != priceArea else { return }
            Log("Price area did change: \(priceArea.title)")
            objectWillChange.send()
            prices = []
            updatePricesIfNeeded()
        }
    }

    @AppStorageCodable("CurrencyConversion")
    private var cachedForex: ForexLatest? = nil

    private var updateTask: Task<Void, Never>?

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
        _ = await updateTask?.result
        if let price = prices.price(for: Date()) {
            if price != currentPrice {
                currentPrice = price
            }
            Log("Update not needed")
            return
        }
        updateTask = Task {
            Log("Begin updating prices")
            do {
                prices = try await getTodaysPrices()
                currentPrice = prices.price(for: Date())
                Log("Success updating prices")
                NotificationCenter.default.post(name: Self.didUpdateDayAheadPrices, object: self)
            } catch {
                LogError(error)
                currentPrice = nil
            }
        }
        _ = await updateTask?.result
    }

    private func getTodaysPrices() async throws -> [PricePoint] {
        Log("Downloading day ahead prices")
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
        s.currentPrice = .mockPrices[10]
        s.prices = PricePoint.mockPrices
        return s
    }()
}
