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
        GeometryReader { geometry in
            VStack {
                Text(entry.formattedPrice(style: .normal))
                    .font(.title)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                DateIntervalText(entry.date, style: .normal)
                    .font(.subheadline)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                PriceChartView(
                    selectedPrice: .constant(nil),
                    currentPrice: entry.pricePoint,
                    prices: entry.prices,
                    limits: entry.limits,
                    pricePresentation: entry.pricePresentation,
                    chartStyle: entry.chartStyle
                )
                .layoutPriority(geometry.size.height <= 120 ? 1 : 0)
            }
            .padding(.all, geometry.size.height < 150 ? 8 : nil)
        }
    }

}

#Preview {
    ScrollView {
        VStack {
            Group {
                PricePointLargeWidgetView(entry: .mock)
                    .frame(height: 100)
                PricePointLargeWidgetView(entry: .mock)
                    .frame(height: 120)
                PricePointLargeWidgetView(entry: .mock)
                    .frame(height: 130)
                PricePointLargeWidgetView(entry: .mock)
                    .frame(height: 140)
                PricePointLargeWidgetView(entry: .mock)
                    .frame(height: 250)
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary, lineWidth: 1)
            }
        }
        .padding()
    }
}
