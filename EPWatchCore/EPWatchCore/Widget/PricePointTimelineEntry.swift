//
//  PricePointTimelineEntry.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-13.
//

import WidgetKit

public struct PricePointTimelineEntry: TimelineEntry {
    
    let pricePoint: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    
    public init(
        pricePoint: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle
    ) {
        self.pricePoint = pricePoint
        self.prices = prices
        self.limits = limits
        self.pricePresentation = pricePresentation
        self.chartStyle = chartStyle
    }
    
    public var date: Date {
        pricePoint.date
    }
    
    public func formattedPrice(style: FormattingStyle) -> String {
        pricePresentation.formattedPrice(pricePoint, style: style)
    }
    
    public func formattedDateTimeInterval(style: FormattingStyle) -> String {
        pricePresentation.formattedDateTimeInterval(from: pricePoint, style: style)
    }
    
    public static let mock = PricePointTimelineEntry(
        pricePoint: .mockPrice,
        prices: .mockPrices,
        limits: .mockLimits,
        pricePresentation: .init(),
        chartStyle: .lineInterpolated
    )
    
    public static let mock2 = PricePointTimelineEntry(
        pricePoint: .mockPrice2,
        prices: .mockPrices,
        limits: PriceLimits(.SEK, high: 3.2, low: 1.4),
        pricePresentation: .init(),
        chartStyle: .lineInterpolated
    )
    
    public static let mock3 = PricePointTimelineEntry(
        pricePoint: .mockPrice3,
        prices: .mockPrices,
        limits: .mockLimits,
        pricePresentation: .init(),
        chartStyle: .lineInterpolated
    )
}
