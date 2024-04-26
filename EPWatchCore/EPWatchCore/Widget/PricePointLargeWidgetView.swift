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
            Text(entry.formattedPrice(style: .normal))
                .font(.title)
            DateIntervalText(entry.date, style: .normal)
                .font(.subheadline)
            PriceChartView(
                selectedPrice: .constant(nil),
                currentPrice: entry.pricePoint,
                prices: entry.prices,
                limits: entry.limits,
                pricePresentation: entry.pricePresentation,
                chartStyle: entry.chartStyle
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
