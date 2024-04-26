//
//  PriceView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

struct PriceView: View {

    let currentPrice: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle

    @State private var selectedPrice: PricePoint? = nil
    var displayedPrice: PricePoint {
        return selectedPrice ?? currentPrice
    }

    init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.pricePresentation = pricePresentation
        self.chartStyle = chartStyle
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
                useCurrencyAxisFormat: true
            )
        }
        .padding(.vertical, 8)
    }

}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .mockLimits,
            pricePresentation: .init(),
            chartStyle: .lineInterpolated
        )
    }
}
