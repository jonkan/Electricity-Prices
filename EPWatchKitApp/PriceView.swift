//
//  PriceView.swift
//  EPWatchWatchKitApp
//
//  Created by Jonas Bromö on 2022-09-13.
//

import SwiftUI
import Charts
import EPWatchCore

struct PriceView: View {

    var currentPrice: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits
    var currencyPresentation: CurrencyPresentation

    var body: some View {
        VStack(spacing: 8) {
            Text(currentPrice.formattedPrice(.normal, currencyPresentation))
                .font(.title)
            Text(currentPrice.formattedTimeInterval(.normal))
                .font(.subheadline)
            PriceChartView(
                currentPrice: currentPrice,
                prices: prices,
                limits: limits,
                useCurrencyAxisFormat: true
            )
        }
    }

}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .mockLimits,
            currencyPresentation: .natural
        )
    }
}

