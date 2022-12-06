//
//  PricesAPI.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import XMLCoder

class PricesAPI {

    static let shared: PricesAPI = PricesAPI()

    private init() {}

    var dateWhenTomorrowsPricesBecomeAvailable: Date {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        return Calendar.current.date(byAdding: .hour, value: 13, to: startOfDay)!
    }

    func downloadDayAheadPrices(for priceArea: PriceArea) async throws -> DayAheadPrices {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: .now)
        let endOfToday = cal.endOfDay(for: .now)
        let endOfTomorrow = cal.date(byAdding: .day, value: 1, to: endOfToday)!

        // The API doesn't seem to require the data to be complete in the requested time period, i.e.
        // we can always request until tomorrow but might only get until today depending on tomorrows
        // availability.
        do {
            return try await downloadDayAheadPrices(for: priceArea, from: startOfToday, to: endOfTomorrow)
        } catch {
            Log("Failed to download prices until end of tomorrow, error: \(error)")
        }
        return try await downloadDayAheadPrices(for: priceArea, from: startOfToday, to: endOfToday)
    }

    func downloadDayAheadPrices(
        for priceArea: PriceArea,
        from startDate: Date,
        to endDate: Date
    ) async throws -> DayAheadPrices {
        Log("Downloading day ahead prices")
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyyMMddHHmm"
        let startDateStr = df.string(from: startDate)
        let endDateStr = df.string(from: endDate)

        let plistToken = Bundle.main.object(forInfoDictionaryKey: "EntsoeSecurityToken")
        guard let securityToken = plistToken as? String, !securityToken.isEmpty else {
            throw NSError(0, "Failed to read EntsoeSecurityToken from Info.plist")
        }
        var components = URLComponents(string: "https://transparency.entsoe.eu/api")!
        components.queryItems = [
            URLQueryItem(name: "documentType", value: "A44"),
            URLQueryItem(name: "in_Domain", value: priceArea.code),
            URLQueryItem(name: "out_Domain", value: priceArea.code),
            URLQueryItem(name: "periodStart", value: startDateStr),
            URLQueryItem(name: "periodEnd", value: endDateStr),
            URLQueryItem(name: "securityToken", value: securityToken)
        ]

        let request = URLRequest(url: components.url!)
        let response = try await SessionManager.shared.download(request)
        let statusCode = response.httpResponse.statusCode
        do {
            let dayAheadPrices = try parseDayAheadPrices(fromXML: response.data)
            Log("Success downloading day ahead prices")
            return dayAheadPrices
        } catch {
            var userPresentableError: UserPresentableError?
            if 200 <= statusCode, statusCode < 300 {
                do {
                    let errorResponse = try parseErrorResponse(fromXML: response.data)
                    userPresentableError = UserPresentableError(errorResponse)
                } catch {
                    LogError("Failed to parse: \(String(data: response.data, encoding: .utf8) ?? "")")
                    throw error
                }
            }
            throw userPresentableError ?? error
        }
    }

    func parseDayAheadPrices(fromXML data: Data) throws -> DayAheadPrices {
        let decoder = XMLDecoder()
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        decoder.dateDecodingStrategy = .formatted(df)
        decoder.keyDecodingStrategy = .convertFromCapitalized
        let dayAheadPrices = try decoder.decode(DayAheadPrices.self, from: data)
        return dayAheadPrices
    }

    func parseErrorResponse(fromXML data: Data) throws -> DayAheadPricesErrorResponse {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        let error = try decoder.decode(DayAheadPricesErrorResponse.self, from: data)
        return error
    }

}
