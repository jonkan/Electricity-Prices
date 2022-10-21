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

    func downloadDayAheadPrices() async throws -> DayAheadPrices {
        let startOfDay = Date()
            .in(region: .current)
            .dateAtStartOf(.day)
            .convertTo(region: .UTC)
        let startOfDayStr = startOfDay
            .toFormat("yyyyMMddHHmm")
        let endOfDayStr = startOfDay.dateByAdding(24, .hour)
            .toFormat("yyyyMMddHHmm")

        var components = URLComponents(string: "https://transparency.entsoe.eu/api")!
        components.queryItems = [
            URLQueryItem(name: "documentType", value: "A44"),
            URLQueryItem(name: "in_Domain", value: "10Y1001A1001A46L"),
            URLQueryItem(name: "out_Domain", value: "10Y1001A1001A46L"),
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromCapitalized
        let dayAheadPrices = try decoder.decode(DayAheadPrices.self, from: data)
        return dayAheadPrices
    }

}
