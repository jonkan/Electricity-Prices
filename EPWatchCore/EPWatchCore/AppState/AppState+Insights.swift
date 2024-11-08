//
//  AppState+Insights.swift
//  EPWatchCore
//
//  Created by Jonas Värbrand on 2024-11-08.
//

import Foundation

public extension AppState {

    var cheapestHours: CheapestHours? {
        // Filter prices that are shown in the chart and are not in the past.
        let filteredPrices = prices.filterForViewMode(chartViewMode)
            .filter({ Calendar.current.startOfHour(for: .now) <= $0.date })
        return filteredPrices.cheapestHours(for: Int(cheapestHoursDuration))
    }

    var priceRangeToday: PriceRange? {
        prices.priceRange(forDayOf: .now)
    }

    var priceRangeTomorrow: PriceRange? {
        prices.priceRange(forDayOf: .nowTomorrow())
    }

}
