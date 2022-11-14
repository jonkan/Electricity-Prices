//
//  PriceView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

struct PriceView: View {

    var currentPrice: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits
    var currencyPresentation: CurrencyPresentation

    @State private var displayedPrice: PricePoint

    init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyPresentation: CurrencyPresentation
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.currencyPresentation = currencyPresentation
        _displayedPrice = .init(initialValue: currentPrice)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(displayedPrice.formattedPrice(.normal, currencyPresentation))
                .font(.title)
            Text(displayedPrice.formattedTimeInterval(.normal))
                .font(.subheadline)
            PriceChartView(
                displayedPrice: $displayedPrice,
                currentPrice: currentPrice,
                prices: prices,
                limits: limits,
                currencyPresentation: currencyPresentation,
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
            currencyPresentation: .automatic
        )
    }
}

