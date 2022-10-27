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

    var body: some View {
        VStack(spacing: 8) {
            Text(currentPrice.formattedPrice(.normal))
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
        .padding(.vertical, 8)
    }

}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .default
        )
    }
}

