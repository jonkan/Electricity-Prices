//
//  PricePointRectangularWidgetView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import SwiftUI

public struct PricePointRectangularWidgetView: View {

    public var entry: PricePointTimelineEntry

    public init(entry: PricePointTimelineEntry) {
        self.entry = entry
    }

    public var body: some View {
        HStack {
            VStack {
                Text(entry.pricePoint.formattedPrice(.short))
                    .bold()
                Text("kr")
            }
            PriceChartView(
                currentPrice: entry.pricePoint,
                prices: entry.prices,
                limits: entry.limits
            )
        }
    }

}

struct PricePointRectangularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PricePointRectangularWidgetView(entry: .mock)
    }
}

