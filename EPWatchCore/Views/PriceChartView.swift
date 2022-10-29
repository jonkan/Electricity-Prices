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
    let currentPrice: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let currencyPresentation: CurrencyPresentation
    let useCurrencyAxisFormat: Bool

    public init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyPresentation: CurrencyPresentation,
        useCurrencyAxisFormat: Bool = false
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.currencyPresentation = currencyPresentation
        self.useCurrencyAxisFormat = useCurrencyAxisFormat
    }

    public var body: some View {
        Chart {
            ForEach(prices, id: \.date) { p in
                LineMark(
                    x: .value("", p.date),
                    y: .value("", p.price(with: currencyPresentation))
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
                    y: .value("", currentPrice.price(with: currencyPresentation))
                )
                .foregroundStyle(.foreground.opacity(0.6))
                .symbolSize(300)

                PointMark(
                    x: .value("", currentPrice.date),
                    y: .value("", currentPrice.price(with: currencyPresentation))
                )
                .foregroundStyle(.background)
                .symbolSize(100)
            }

            PointMark(
                x: .value("", currentPrice.date),
                y: .value("", currentPrice.price(with: currencyPresentation))
            )
            .foregroundStyle(limits.color(of: currentPrice.price))
            .symbolSize(70)
        }
        .widgetAccentable()
        .chartYAxis {
            if let axisYValues = axisYValues {
                // TODO: Figure out how to present subdivided units (e.g. Cent)
                if useCurrencyAxisFormat && currencyPresentation != .subdivided {
                    AxisMarks(
                        format: currencyAxisFormat,
                        values: axisYValues
                    )
                } else {
                    AxisMarks(values: axisYValues)
                }
            } else {
                if useCurrencyAxisFormat && currencyPresentation != .subdivided {
                    AxisMarks(format: currencyAxisFormat)
                } else {
                    AxisMarks()
                }
            }
        }
        .padding(.top, widgetRenderingMode != .fullColor ? 5 : 0)
    }

    var axisYValues: [Double]? {
        if currentPrice.dayPriceRange.upperBound <= 1.5 && currencyPresentation != .subdivided {
            return [0.0, 0.5, 1.0, 1.5]
        }
        return nil
    }

    var currencyAxisFormat: FloatingPointFormatStyle<Double>.Currency {
        if currentPrice.dayPriceRange.upperBound <= 10 {
            return .currency(code: currentPrice.currency.code).precision(.fractionLength(1))
        }
        return .currency(code: currentPrice.currency.code).precision(.significantDigits(2))
    }

}

private extension PricePoint {
    func price(with currencyPresentation: CurrencyPresentation) -> Double {
        switch currencyPresentation {
        case .automatic:
            return price
        case .subdivided:
            return price * currency.subdivision.subdivisions
        }
    }
}

struct PriceChartView_Previews: PreviewProvider {
    static var previews: some View {
        PriceChartView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .mockLimits,
            currencyPresentation: .automatic
        )
    }
}

