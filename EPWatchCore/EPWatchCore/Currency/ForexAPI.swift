//
//  ForexAPI.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import Alamofire

enum ForexError: Error {
    case outdatedRate
}

class ForexAPI {
    static let shared: ForexAPI = ForexAPI()

    private init() {}

    func download(from: Currency, to: Currency) async throws -> ExchangeRate {
        let maxNumberOfTries = 7
        for attempt in 1...maxNumberOfTries {
            let startDate = Calendar.current.date(byAdding: .day, value: -attempt, to: .now)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startPeriod = dateFormatter.string(from: startDate)

            guard from != to else {
                return ExchangeRate(date: startPeriod, from: from, to: to, rate: 1)
            }

            var components = URLComponents(string: "https://data-api.ecb.europa.eu/service/data/EXR/D.\(to).\(from).SP00.A")!
            components.queryItems = [
                URLQueryItem(name: "format", value: "csvdata"),
                URLQueryItem(name: "startPeriod", value: startPeriod)
            ]

            var statusCode: Int?
            var responseString: String?
            do {
                let downloadResponse = await AF.download(components.url!).serializingData().response
                let data = try downloadResponse.result.get()
                statusCode = downloadResponse.response?.statusCode

                guard let csv = String(data: data, encoding: .utf8) else {
                    throw NSError(0, "Failed to decode string from data")
                }
                responseString = csv
                let lines = csv.split(whereSeparator: \.isNewline)
                guard lines.count >= 2 else {
                    throw NSError(0, "Failed, csv not 2 (or more) lines")
                }
                let values = lines[1].split(separator: ",")
                guard values.count >= 7 else {
                    throw NSError(0, "Unexpected csv data, too few values")
                }
                guard values[2] == to.code, values[3] == from.code else {
                    throw NSError(0, "Unexpected csv data")
                }
                guard let rate = Double(values[7]) else {
                    throw NSError(0, "Unable to parse rate from csv data")
                }
                return ExchangeRate(date: startPeriod, from: from, to: to, rate: rate)
            } catch {
                LogError("Failed to fetch exchange rate for date \(startPeriod), attempt \(attempt), error: \(error), response: \(responseString ?? ""), statusCode: \(statusCode ?? 0)")
            }
        }
        throw NSError(0, "Failed to fetch exchange rate in \(maxNumberOfTries) attempts")
    }

}
