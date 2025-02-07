//
//  AppStateDTO.swift
//
//
//  Created by Jonas Bromö on 2023-09-22.
//

import Foundation

public let EncodedAppStateApplicationContextKey = "EncodedAppStateDTO"

public struct AppStateDTO: Codable, Equatable, Sendable {
    let prices: [PricePoint]
    let region: Region?
    let priceArea: PriceArea?
    let currency: Currency
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    let allPriceLimits: [Currency: PriceLimits]
    let exchangeRates: [Currency: ExchangeRate]
    let cheapestHoursDuration: Double
    let showCheapestHours: Bool

    public func encodeToApplicationContext() throws -> [String: Any] {
        let encodedAppStateDTO = try JSONEncoder().encode(self)
        let context = [EncodedAppStateApplicationContextKey: encodedAppStateDTO]
        return context
    }

    public static func decode(from applicationContext: [String: Any]) throws -> AppStateDTO? {
        guard let encodedAppStateDTO = applicationContext[EncodedAppStateApplicationContextKey] as? Data else {
            return nil
        }
        let appStateDTO = try JSONDecoder().decode(
            AppStateDTO.self,
            from: encodedAppStateDTO
        )
        return appStateDTO
    }
}

extension AppState {
    public func toDTO() -> AppStateDTO {
        AppStateDTO(
            prices: prices,
            region: region,
            priceArea: priceArea,
            currency: currency,
            pricePresentation: pricePresentation,
            chartStyle: chartStyle,
            allPriceLimits: allPriceLimits,
            exchangeRates: exchangeRates,
            cheapestHoursDuration: cheapestHoursDuration,
            showCheapestHours: showCheapestHours
        )
    }

    public func update(from dto: AppStateDTO) {
        prices = dto.prices
        region = dto.region
        priceArea = dto.priceArea
        currency = dto.currency
        pricePresentation = dto.pricePresentation
        chartStyle = dto.chartStyle
        allPriceLimits = dto.allPriceLimits
        exchangeRates = dto.exchangeRates
        cheapestHoursDuration = dto.cheapestHoursDuration
        showCheapestHours = dto.showCheapestHours
    }
}
