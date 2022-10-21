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
    @Published var formattedCurrentPrice: String?

    @AppStorageCodable("prices")
    private var prices: [PricePoint]?

    @AppStorageCodable("CurrencyConversion")
    private var cachedForex: ForexLatest?

    private let priceNumberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.maximumSignificantDigits = 3
        nf.currencyCode = "SEK"
        return nf
    }()
    private var isUpdatingCurrentPrice: Bool = false

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
        isUpdatingCurrentPrice = true
        Log("Update current price begin")
        Task {
            do {
                let price = try await currentPrice()
                guard let priceText = priceNumberFormatter.string(from: price as NSNumber) else {
                    throw NSError(0, "Failed to format price")
                }
                formattedCurrentPrice = priceText
                Log("Update current price success")
            } catch {
                formattedCurrentPrice = nil
                LogError(error)
            }
            isUpdatingCurrentPrice = false
        }
    }

    private func currentPrice() async throws -> Double {
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
