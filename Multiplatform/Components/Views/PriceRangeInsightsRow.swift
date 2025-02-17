//
//  InsightsView.swift
//  Electricity Prices
//
//  Created by Jonas Värbrand on 2024-11-08.
//

import SwiftUI
import Core

struct PriceRangeInsightsRow: View {

    let title: LocalizedStringKey
    let priceRange: PriceRange
    let currency: Currency
    let pricePresentation: PricePresentation
    let priceLimits: PriceLimits

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)

            let columns: [GridItem] = [
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .trailing)
            ]
            LazyVGrid(columns: columns) {
                Group {
                    Text("High price", comment: "Title for the highest price")
                    Text("Low price", comment: "Title for the lowest price")
                    Text("Average price", comment: "Title for the mean price")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                formattedPriceLabel(priceRange.max)
                formattedPriceLabel(priceRange.min)
                formattedPriceLabel(priceRange.mean)
            }
        }
    }

    private func formattedPriceLabel(_ price: Double) -> some View {
        Text(
            pricePresentation.formattedPrice(
                price,
                in: currency,
                style: .normal
            )
        )
        .font(.headline)
        .foregroundStyle(priceLimits.color(of: price))
    }

}

#Preview {
    let prices: [PricePoint] = .mockedPricesWithTomorrow2

    List {
        PriceRangeInsightsRow(
            title: "Today",
            priceRange: prices.priceRange(forDayOf: .now)!,
            currency: .SEK,
            pricePresentation: .mocked,
            priceLimits: .mocked
        )
        PriceRangeInsightsRow(
            title: "Tomorrow",
            priceRange: prices.priceRange(forDayOf: .nowTomorrow())!,
            currency: .SEK,
            pricePresentation: .mocked,
            priceLimits: .mocked
        )
    }
}
