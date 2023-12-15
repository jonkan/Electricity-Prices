//
//  PricePointRectangularWidgetView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import SwiftUI

public struct PricePointRectangularWidgetView: View {

    let entry: PricePointTimelineEntry

    public init(entry: PricePointTimelineEntry) {
        self.entry = entry
    }

    public var body: some View {
        PriceChartView(
            selectedPrice: .constant(nil),
            currentPrice: entry.pricePoint,
            prices: entry.prices,
            limits: entry.limits,
            pricePresentation: entry.pricePresentation,
            chartStyle: entry.chartStyle
        )
        .chartYScale(
            range: .plotDimension(
                startPadding: 0,
                endPadding: 6
            )
        )
    }

}

struct PricePointRectangularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PricePointRectangularWidgetView(entry: .mock)
    }
}

