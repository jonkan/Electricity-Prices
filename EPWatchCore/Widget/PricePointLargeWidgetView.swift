//
//  PricePointLargeWidgetView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import SwiftUI

public struct PricePointLargeWidgetView: View {

    let entry: PricePointTimelineEntry

    public init(entry: PricePointTimelineEntry) {
        self.entry = entry
    }

    public var body: some View {
        VStack(spacing: 8) {
            Text(entry.pricePoint.formattedPrice(.normal, entry.currencyPresentation))
                .font(.title)
            Text(entry.pricePoint.formattedTimeInterval(.normal))
                .font(.subheadline)
            PriceChartView(
                currentPrice: entry.pricePoint,
                prices: entry.prices,
                limits: entry.limits,
                currencyPresentation: entry.currencyPresentation
            )
        }
        .padding()
    }

}

struct PricePointLargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PricePointLargeWidgetView(entry: .mock)
    }
}

