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
    case outdatedRate
}

struct ForexRate: Codable {
    static private let df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    let date: String // "2022-09-07"
    let from: Currency
    let to: Currency
    let rate: Double // 10.700151

    var isUpToDate: Bool {
        let d = ForexRate.df.date(from: date) ?? .distantPast
        let friday = 6 // Doc: Sunday is 1
        let cal = Calendar.current
        return (
            cal.isDateInToday(d) ||
            (
                cal.isDateInWeekend(d) &&
                cal.component(.weekday, from: d) == friday
            )
        )
    }
}

class ForexAPI {
    static let shared: ForexAPI = ForexAPI()

    private init() {}

    func download(from: Currency, to: Currency) async throws -> ForexRate {
        var startDate = (DateInRegion() - 1.days)
        while startDate.isInWeekend {
            startDate = startDate - 1.days
        }
        let startPeriod = startDate.toFormat("yyyy-MM-dd")

        guard from != to else {
            return ForexRate(date: startPeriod, from: from, to: to, rate: 1)
        }

        var components = URLComponents(string: "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.\(to).\(from).SP00.A")!
        components.queryItems = [
            URLQueryItem(name: "format", value: "csvdata"),
            URLQueryItem(name: "startPeriod", value: startPeriod)
        ]
        let downloadResponse = await AF.download(components.url!).serializingData().response
        let data = try downloadResponse.result.get()
        let statusCode = downloadResponse.response?.statusCode
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
            guard values[2] == to.code, values[3] == from.code else {
                throw NSError(0, "Unexpected csv data")
            }
            guard let rate = Double(values[7]) else {
                throw NSError(0, "Unable to parse rate from csv data")
            }
            return ForexRate(date: startPeriod, from: from, to: to, rate: rate)
        } catch {
            LogError("Failed to parse: \(String(data: data, encoding: .utf8) ?? ""), statusCode: \(statusCode ?? 0)")
            throw error
        }

    }

}
