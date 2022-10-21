//
//  AppState.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-06.
//

import Foundation

@MainActor
class AppState: ObservableObject {

    static let shared: AppState = AppState()
    @Published var currentPrice: Double?

    private init() {
        downloadDayAheadPrices()
    }

    func downloadDayAheadPrices() {
        Task {
            do {
                let startOfDay = Date()
                    .in(region: .current)
                    .dateAtStartOf(.day)
                    .convertTo(region: .UTC)
                let startOfDayStr = startOfDay
                    .toFormat("yyyyMMddHHmm")
                let endOfDayStr = startOfDay.dateByAdding(24, .hour)
                    .toFormat("yyyyMMddHHmm")

                var urlComponents = URLComponents(string: "https://transparency.entsoe.eu/api")!
                urlComponents.queryItems = [
                    URLQueryItem(name: "documentType", value: "A44"),
                    URLQueryItem(name: "in_Domain", value: "10Y1001A1001A46L"),
                    URLQueryItem(name: "out_Domain", value: "10Y1001A1001A46L"),
                    URLQueryItem(name: "periodStart", value: startOfDayStr),
                    URLQueryItem(name: "periodEnd", value: endOfDayStr),
                    URLQueryItem(name: "securityToken", value: "<redacted>")
                ]
                print("URL: \(urlComponents.url!)")

                let (data, _) = try await URLSession.shared.data(from: urlComponents.url!)
                let dayAheadPrices = try parseDayAheadPrices(fromXML: data)
                currentPrice = try dayAheadPrices.priceAmount(for: Date())
            } catch {
                LogError(error)
                currentPrice = nil
            }
        }
    }

    func update(dayAheadPrices: DayAheadPrices) {

    }

}
