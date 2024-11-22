//
//  File.swift
//  EPWatchCore
//
//  Created by Jonas Värbrand on 2024-11-22.
//

import Foundation

extension AppState {
    public static let mocked: AppState = {
        let s: AppState = .shared
        s.currentPrice = .mockPrice
        s.region = .sweden
        s.priceArea = Region.sweden.priceAreas.first
        s.prices = .mockPricesWithTomorrow
        s.exchangeRate = .mockedSEK
        s.chartViewMode = .todayAndComingNight
        return s
    }()

    public static let mockedTodayAndTomorrow: AppState = {
        let s: AppState = .shared
        s.currentPrice = .mockPrice
        s.region = .sweden
        s.priceArea = Region.sweden.priceAreas.first
        s.prices = .mockPricesWithTomorrow
        s.exchangeRate = .mockedSEK
        s.chartViewMode = .todayAndTomorrow
        return s
    }()

    public static let mockedNowAndAllAhead: AppState = {
        let s: AppState = .shared
        s.currentPrice = .mockPrice
        s.region = .sweden
        s.priceArea = Region.sweden.priceAreas.first
        s.prices = .mockPricesWithTomorrow
        s.exchangeRate = .mockedSEK
        s.chartViewMode = .nowAndAllAhead
        return s
    }()

    public static let mockedWithError: AppState = {
        let s: AppState = .shared
        s.currentPrice = nil
        s.region = .sweden
        s.priceArea = Region.sweden.priceAreas.first
        s.userPresentableError = .noData
        return s
    }()
}
