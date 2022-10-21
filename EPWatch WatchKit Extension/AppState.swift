//
//  AppState.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {

    static let shared: AppState = AppState()
    @Published var currentPrice: Double?

    @AppStorageCodable("prices")
    var prices: [PricePoint]?

    @AppStorageCodable("CurrencyConversion")
    var cachedForex: ForexLatest?

    private init() {
        downloadDayAheadPricesIfNeeded()
    }

    func downloadDayAheadPricesIfNeeded() {
        Task {
            do {
                if prices == nil || prices?.contains(where: { $0.start.isToday }) == false {
                    let dayAheadPrices = try await downloadDayAheadPrices()
                    let forex = try await currentForex()
                    let rate = try forex.rate(from: "EUR", to: "SEK")
                    prices = dayAheadPrices.prices(using: rate)
                }
            } catch {
                LogError(error)
                currentPrice = nil
            }
        }
    }

    

    func updateCurrentPrice() {

    }

    func update(dayAheadPrices: DayAheadPrices) {

    }

//    func downloadForexIfNeeded() {
//        Task {
//            do {
//                try await currentForex()
//            } catch {
//                LogError(error)
//            }
//        }
//    }

    func currentForex() async throws -> ForexLatest {
        if let forex = cachedForex, forex.isUpToDate {
            return forex
        }
        let res = try await ForexAPI.shared.download()
        cachedForex = res
        return res
    }

}
