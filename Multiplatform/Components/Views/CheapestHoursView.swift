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
    @Binding var showInMainChart: Bool
    @State private var selectedPrice: PricePoint?
    var displayedPrice: FormattablePrice {
        return selectedPrice ?? cheapestHours
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 4) {
                    Text(pricePresentation.formattedPrice(displayedPrice, style: .normal))
                        .font(.title)

                    Group {
                        if let selectedPrice {
                            DateIntervalText(selectedPrice.date, style: .normal)
                        } else {
                            DateIntervalText(
                                cheapestHours.start,
                                duration: (cheapestHours.duration, .hour),
                                style: .normal
                            )
                        }
                    }
                    .font(.subheadline)
                    .padding(.bottom, 4)

                    PriceChartView(
                        selectedPrice: $selectedPrice,
                        currentPrice: currentPrice,
                        prices: prices,
                        limits: limits,
                        pricePresentation: pricePresentation,
                        chartStyle: chartStyle,
                        useCurrencyAxisFormat: true,
                        cheapestHours: cheapestHours,
                        minHeight: 130
                    )
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
                Toggle("Show in main chart and widgets", isOn: $showInMainChart)
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
        limits: .mocked,
        pricePresentation: .mocked,
        chartStyle: chartStyle,
        cheapestHours: prices
            .filter({ Calendar.current.startOfHour(for: currentPrice.date) <= $0.date })
            .cheapestHours(for: Int(duration))!,
        cheapestHoursDuration: $duration,
        showInMainChart: .constant(true)
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
