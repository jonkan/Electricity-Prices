//
//  AppState+Insights.swift
//  Core
//
//  Created by Jonas Värbrand on 2024-11-08.
//

import Foundation

public extension AppState {

    func cheapestHours(for date: Date) -> CheapestHours? {
        // Filter prices that are shown in the chart and are not in the past.
        let filteredPrices = prices.filterForViewMode(chartViewMode)
            .filter({ Calendar.current.startOfHour(for: date) <= $0.date })
        return filteredPrices.cheapestHours(for: Int(cheapestHoursDuration))
    }

    var priceRangeToday: PriceRange? {
        prices.priceRange(forDayOf: .now)
    }

    var priceRangeTomorrow: PriceRange? {
        prices.priceRange(forDayOf: .nowTomorrow())
    }

}
