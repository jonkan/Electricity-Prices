//
//  ForexAPI.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation

enum ForexError: Error {
    case wrongBase
    case missingRate
    case ratesTooOld
}

struct ForexLatest: Codable {
    var base: String // "EUR"
    var date: String // "2022-09-07"
    var rates: [String: Double] // { "SEK": 10.700151 }

    var isUpToDate: Bool {
        return date.toDate("yyyy-MM-dd", region: .UTC)?.isToday == true
    }

    func rate(from: String, to: String) throws -> Double {
        guard from == base else {
            throw ForexError.wrongBase
        }
        guard let rate = rates[to] else {
            throw ForexError.missingRate
        }
        return rate
    }
}

class ForexAPI {
    static let shared: ForexAPI = ForexAPI()

    private init() {}

    func download() async throws -> ForexLatest {
        var components = URLComponents(string: "https://api.apilayer.com/fixer/latest")!
        components.queryItems = [
            URLQueryItem(name: "symbols", value: "SEK"), // Comma separated list
            URLQueryItem(name: "base", value: "EUR"),
            URLQueryItem(name: "apikey", value: "V7ChaSkcNEUXV2I0Z9ac4EqyzWkuNj7C")
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        do {
            let response = try JSONDecoder().decode(ForexLatest.self, from: data)
            return response
        } catch {
            LogError("Failed to parse: \(String(data: data, encoding: .utf8) ?? "")")
            throw error
        }
    }

}
