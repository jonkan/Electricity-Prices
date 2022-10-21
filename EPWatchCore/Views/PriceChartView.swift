//
//  File.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import Charts
import WidgetKit

public struct PriceChartView: View {

    var currentPrice: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits

    public init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
    }

    public var body: some View {
        Chart {
            ForEach(prices, id: \.date) { p in
                LineMark(
                    x: .value("", p.date),
                    y: .value("Kr", p.price)
                )
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(LinearGradient(
                stops: limits.stops(using: currentPrice.dayPriceRange),
                startPoint: .bottom,
                endPoint: .top
            ))
            RuleMark(
                x: .value("", currentPrice.date)
            )
            .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [3, 6]))
            .foregroundStyle(.gray)
            PointMark(
                x: .value("", currentPrice.date),
                y: .value("", currentPrice.price)
            )
            .foregroundStyle(.foreground.opacity(0.6))
            .symbolSize(300)
            PointMark(
                x: .value("", currentPrice.date),
                y: .value("", currentPrice.price)
            )
            .foregroundStyle(.background)
            .symbolSize(100)
            PointMark(
                x: .value("", currentPrice.date),
                y: .value("", currentPrice.price)
            )
            .foregroundStyle(limits.color(of: currentPrice.price))
            .symbolSize(70)

        }
        .widgetAccentable()
    }

}

struct PriceChartView_Previews: PreviewProvider {
    static var previews: some View {
        PriceChartView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .default
        )
    }
}

