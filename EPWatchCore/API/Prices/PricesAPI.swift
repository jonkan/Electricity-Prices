//
//  PricesAPI.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import Alamofire
import XMLCoder

class PricesAPI {

    static let shared: PricesAPI = PricesAPI()

    private init() {}

    func downloadDayAheadPrices(for priceArea: PriceArea) async throws -> DayAheadPrices {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: .now)
        let endOfDay = cal.date(byAdding: .hour, value: 24, to: startOfDay)!

        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_GB")
        df.dateFormat = "yyyyMMddHHmm"
        let startOfDayStr = df.string(from: startOfDay.date)
        let endOfDayStr = df.string(from: endOfDay)

        var components = URLComponents(string: "https://transparency.entsoe.eu/api")!
        components.queryItems = [
            URLQueryItem(name: "documentType", value: "A44"),
            URLQueryItem(name: "in_Domain", value: priceArea.domain),
            URLQueryItem(name: "out_Domain", value: priceArea.domain),
            URLQueryItem(name: "periodStart", value: startOfDayStr),
            URLQueryItem(name: "periodEnd", value: endOfDayStr),
            URLQueryItem(name: "securityToken", value: "<redacted>")
        ]

        let downloadResponse = await AF.download(components.url!).serializingData().response
        let data = try downloadResponse.result.get()
        do {
            let dayAheadPrices = try parseDayAheadPrices(fromXML: data)
            return dayAheadPrices
        } catch {
            if let statusCode = downloadResponse.response?.statusCode, 200 <= statusCode, statusCode < 300 {
                LogError("Failed to parse: \(String(data: data, encoding: .utf8) ?? "")")
            }
            throw error
        }
    }

    func parseDayAheadPrices(fromXML data: Data) throws -> DayAheadPrices {
        let decoder = XMLDecoder()
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_GB")
        df.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        decoder.dateDecodingStrategy = .formatted(df)
        decoder.keyDecodingStrategy = .convertFromCapitalized
        let dayAheadPrices = try decoder.decode(DayAheadPrices.self, from: data)
        return dayAheadPrices
    }

}
