//
//  PricePointTimelineEntry.swift
//  Core
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit

public struct PricePointTimelineEntry: TimelineEntry {

    let pricePoint: PricePoint
    let prices: [PricePoint]
    let priceRange: PriceRange
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    let cheapestHours: CheapestHours?

    public init(
        pricePoint: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle,
        cheapestHours: CheapestHours? = nil
    ) {
        self.pricePoint = pricePoint
        self.prices = prices
        self.priceRange = prices.priceRange() ?? .zero
        self.limits = limits
        self.pricePresentation = pricePresentation
        self.chartStyle = chartStyle
        self.cheapestHours = cheapestHours
    }

    public var date: Date {
        pricePoint.date
    }

    public func formattedPrice(style: FormattingStyle) -> String {
        pricePresentation.formattedPrice(pricePoint, style: style)
    }

    public static let mocked = PricePointTimelineEntry(
        pricePoint: .mockedPrice,
        prices: .mockedPrices,
        limits: .mocked,
        pricePresentation: .init(),
        chartStyle: .bar
    )

    public static let mocked2 = PricePointTimelineEntry(
        pricePoint: [PricePoint].mockedPricesLow[8],
        prices: .mockedPricesLow,
        limits: PriceLimits(.SEK, high: 3.2, low: 1.4),
        pricePresentation: .init(),
        chartStyle: .bar
    )

    public static let mockedTodayAndComingNight: PricePointTimelineEntry = {
        let prices: [PricePoint] = .mockedPricesWithTomorrow
        let price = prices[14]
        let entry = PricePointTimelineEntry(
            pricePoint: price,
            prices: prices.filterForViewMode(.todayAndComingNight, at: price.date),
            limits: .mocked,
            pricePresentation: .init(),
            chartStyle: .bar
        )
        return entry
    }()

    public static let mockedTodayAndTomorrow: PricePointTimelineEntry = {
        let prices: [PricePoint] = .mockedPricesWithTomorrow
        let price = prices[14]
        let entry = PricePointTimelineEntry(
            pricePoint: price,
            prices: prices.filterForViewMode(.todayAndTomorrow, at: price.date),
            limits: .mocked,
            pricePresentation: .init(),
            chartStyle: .bar
        )
        return entry
    }()

    public static let mockedNowAndAllAhead1: PricePointTimelineEntry = {
        let prices: [PricePoint] = .mockedPrices
        let price = prices[10]
        let entry = PricePointTimelineEntry(
            pricePoint: price,
            prices: prices.filterForViewMode(.nowAndUpcoming, at: price.date),
            limits: .mocked,
            pricePresentation: .init(),
            chartStyle: .bar
        )
        return entry
    }()

    public static let mockedNowAndAllAhead2: PricePointTimelineEntry = {
        let prices: [PricePoint] = .mockedPricesWithTomorrow
        let price = prices[14]
        let entry = PricePointTimelineEntry(
            pricePoint: price,
            prices: prices.filterForViewMode(.nowAndUpcoming, at: price.date),
            limits: .mocked,
            pricePresentation: .init(),
            chartStyle: .bar
        )
        return entry
    }()
}
