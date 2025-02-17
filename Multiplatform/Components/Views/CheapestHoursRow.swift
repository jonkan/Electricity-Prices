//
//  CheapestHoursRow.swift
//  Electricity Prices
//
//  Created by Jonas Värbrand on 2024-11-08.
//

import SwiftUI
import Core

struct CheapestHoursRow: View {

    let cheapestHours: CheapestHours
    let pricePresentation: PricePresentation
    let limits: PriceLimits

    var body: some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .trailing)
        ]
        LazyVGrid(columns: columns, alignment: .center) {
            Text("Cheapest \(cheapestHours.duration) hours")
                .font(.subheadline)
            Text("Average price")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            DateIntervalText(
                cheapestHours.start,
                duration: (cheapestHours.duration, .hour),
                style: .normal
            )
            .font(.headline)
            Text(
                pricePresentation.formattedPrice(
                    cheapestHours,
                    style: .normal
                )
            )
            .font(.headline)
            .foregroundStyle(limits.color(of: cheapestHours.price))
        }
    }

}

#Preview {
    List {
        CheapestHoursRow(
            cheapestHours: [PricePoint].mockPricesWithTomorrow.cheapestHours(for: 3)!,
            pricePresentation: .mocked,
            limits: .mocked
        )
    }
}
