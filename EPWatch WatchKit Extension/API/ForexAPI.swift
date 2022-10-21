//
//  ForexAPI.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import SwiftDate
import Alamofire

enum ForexError: Error {
    case wrongFrom
    case wrongTo
    case outdatedRate
}

struct ForexLatest: Codable {
    var date: String // "2022-09-07"
    var from: String // "EUR"
    var to: String   // "SEK"
    var rate: Double // 10.700151

    var isUpToDate: Bool {
        return date.toDate("yyyy-MM-dd")?.isToday == true
    }

    func rate(from: String, to: String) throws -> Double {
        guard from == from else {
            throw ForexError.wrongFrom
        }
        guard to == to else {
            throw ForexError.wrongTo
        }
        return rate
    }
}

class ForexAPI {
    static let shared: ForexAPI = ForexAPI()

    private init() {}

    func download(from: String = "EUR", to: String = "SEK") async throws -> ForexLatest {
        let yesterday = (DateInRegion() - 1.days)
            .toFormat("yyyy-MM-dd")
        var components = URLComponents(string: "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.\(to).\(from).SP00.A")!
        components.queryItems = [
            URLQueryItem(name: "format", value: "csvdata"),
            URLQueryItem(name: "startPeriod", value: yesterday)
        ]
        let downloadResponse = await AF.download(components.url!).serializingData().response
        let data = try downloadResponse.result.get()
        do {
            guard let csv = String(data: data, encoding: .utf8) else {
                throw NSError(0, "Failed to decode string from data")
            }
            let lines = csv.split(whereSeparator: \.isNewline)
            guard lines.count >= 2 else {
                throw NSError(0, "Failed, csv not 2 (or more) lines")
            }
            let values = lines[1].split(separator: ",")
            guard values.count >= 7 else {
                throw NSError(0, "Unexpected csv data, too few values")
            }
            guard values[2] == to, values[3] == from else {
                throw NSError(0, "Unexpected csv data")
            }
            guard let rate = Double(values[7]) else {
                throw NSError(0, "Unable to parse rate from csv data")
            }
            return ForexLatest(date: yesterday, from: from, to: to, rate: rate)
        } catch {
            LogError("Failed to parse: \(String(data: data, encoding: .utf8) ?? "")")
            throw error
        }

    }

//    func download() async throws -> ForexLatest {
//        var components = URLComponents(string: "https://api.apilayer.com/fixer/latest")!
//        components.queryItems = [
//            URLQueryItem(name: "symbols", value: "SEK"), // Comma separated list
//            URLQueryItem(name: "base", value: "EUR"),
//            URLQueryItem(name: "apikey", value: "V7ChaSkcNEUXV2I0Z9ac4EqyzWkuNj7C")
//        ]
//
//        let (data, _) = try await URLSession.shared.data(from: components.url!)
//        do {
//            let response = try JSONDecoder().decode(ForexLatest.self, from: data)
//            return response
//        } catch {
//            LogError("Failed to parse: \(String(data: data, encoding: .utf8) ?? "")")
//            throw error
//        }
//    }

}
