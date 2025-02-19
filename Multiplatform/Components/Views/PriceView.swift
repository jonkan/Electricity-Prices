//
//  PriceView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import Core

struct PriceView: View {

    let currentPrice: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    let cheapestHours: CheapestHours?
    let minChartHeight: CGFloat?

    @State private var selectedPrice: PricePoint? = nil
    var displayedPrice: PricePoint {
        return selectedPrice ?? currentPrice
    }

    init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle,
        cheapestHours: CheapestHours? = nil,
        minChartHeight: CGFloat? = nil
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.pricePresentation = pricePresentation
        self.chartStyle = chartStyle
        self.cheapestHours = cheapestHours
        self.minChartHeight = minChartHeight
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(pricePresentation.formattedPrice(displayedPrice, style: .normal))
                .font(.title)
            DateIntervalText(displayedPrice.date, style: .normal)
                .font(.subheadline)
            PriceChartView(
                selectedPrice: $selectedPrice,
                currentPrice: currentPrice,
                prices: prices,
                limits: limits,
                pricePresentation: pricePresentation,
                chartStyle: chartStyle,
                useCurrencyAxisFormat: true,
                cheapestHours: cheapestHours,
                minHeight: minChartHeight
            )
        }
        .padding(.vertical, 8)
    }

}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(
            currentPrice: .mockedPrice,
            prices: .mockedPrices,
            limits: .mocked,
            pricePresentation: .mocked,
            chartStyle: .lineInterpolated
        )
    }
}
