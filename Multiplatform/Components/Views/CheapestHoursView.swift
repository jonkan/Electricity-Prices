//
//  CheapestHoursView.swift
//  Electricity Prices
//
//  Created by Jonas Bromö on 2024-11-01.
//

import SwiftUI
import EPWatchCore

struct CheapestHoursView: View {

    let currentPrice: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle
    let cheapestHours: CheapestHours
    @Binding var cheapestHoursDuration: Double

    var body: some View {
        List {
            Section {
                VStack(spacing: 4) {
                    Text(pricePresentation.formattedPrice(cheapestHours, style: .normal))
                        .font(.title)

                    DateIntervalText(
                        cheapestHours.start,
                        duration: (cheapestHours.duration, .hour),
                        style: .normal
                    )
                    .font(.subheadline)
                    .padding(.bottom, 4)

                    PriceChartView(
                        currentPrice: currentPrice,
                        prices: prices,
                        limits: limits,
                        pricePresentation: pricePresentation,
                        chartStyle: chartStyle,
                        useCurrencyAxisFormat: true,
                        cheapestHours: cheapestHours
                    )
                    .frame(minHeight: 130)
                }
                .padding(.vertical, 8)
            } footer: {
                Text("Average price for the \(cheapestHours.duration) cheapest upcoming hours.")
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Cheapest \(cheapestHours.duration) hours")
                        .monospacedDigit()
                    Slider(value: $cheapestHoursDuration, in: 1...12, step: 1)
                }
            }
        }
    }

}

#Preview {
    @Previewable @State var duration: Double = 3
    @Previewable @State var chartStyle: PriceChartStyle = .bar
    @Previewable @State var viewMode: PriceChartViewMode = .todayAndTomorrow

    var prices: [PricePoint] { .mockedPricesWithTomorrow2.filterForViewMode(viewMode) }
    var currentPrice: PricePoint { prices[14] }

    CheapestHoursView(
        currentPrice: currentPrice,
        prices: prices,
        limits: .mockLimits,
        pricePresentation: .init(),
        chartStyle: chartStyle,
        cheapestHours: prices
            .filter({ Calendar.current.startOfHour(for: currentPrice.date) <= $0.date })
            .cheapestHours(for: Int(duration))!,
        cheapestHoursDuration: $duration
    )
    .safeAreaInset(edge: .top) {
        VStack {
            Picker(selection: $chartStyle) {
                ForEach(PriceChartStyle.allCases) { style in
                    Text(style.title)
                        .tag(style)
                }
            } label: {
                Text(verbatim: "Chart Style")
            }
            .pickerStyle(.segmented)
            Picker(selection: $viewMode) {
                ForEach(PriceChartViewMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            } label: {
                Text(verbatim: "View Mode")
            }
            .pickerStyle(.segmented)
        }
    }
}
