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

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    var currentPrice: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits
    var currencyAxisFormat: Bool

    public init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyAxisFormat: Bool = false
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.currencyAxisFormat = currencyAxisFormat
    }

    public var body: some View {
        Chart {
            ForEach(prices, id: \.date) { p in
                LineMark(
                    x: .value("", p.date),
                    y: .value("kr", p.price)
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

            if widgetRenderingMode == .fullColor {
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
            }

            PointMark(
                x: .value("", currentPrice.date),
                y: .value("", currentPrice.price)
            )
            .foregroundStyle(limits.color(of: currentPrice.price))
            .symbolSize(70)
        }
        .widgetAccentable()
        .chartYAxis {
            if let axisYValues = axisYValues {
                if currencyAxisFormat {
                    AxisMarks(
                        format: .currency(code: "SEK").precision(precision),
                        values: axisYValues
                    )
                } else {
                    AxisMarks(values: axisYValues)
                }
            } else {
                if currencyAxisFormat {
                    AxisMarks(
                        format: .currency(code: "SEK").precision(precision)
                    )
                } else {
                    AxisMarks()
                }
            }
        }
        .padding(.top, widgetRenderingMode != .fullColor ? 5 : 0)
    }

    var axisYValues: [Double]? {
        if currentPrice.dayPriceRange.upperBound <= 1.5 {
          return [0.0, 0.5, 1.0, 1.5]
        }
        return nil
    }

    var precision: NumberFormatStyleConfiguration.Precision {
        if currentPrice.dayPriceRange.upperBound <= 1.5 {
            return .fractionLength(1)
        }
        return .significantDigits(1)
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

