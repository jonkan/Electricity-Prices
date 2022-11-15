//
//  PriceView.swift
//  EPWatchWatchKitApp
//
//  Created by Jonas Bromö on 2022-09-13.
//

import SwiftUI
import EPWatchCore

struct PriceView: View {

    var currentPrice: PricePoint
    var prices: [PricePoint]
    var limits: PriceLimits
    var currencyPresentation: CurrencyPresentation

    @State private var displayedPrice: PricePoint
    @State private var crownValue: Double

    private var calendar: Calendar = .current

    init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyPresentation: CurrencyPresentation
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.currencyPresentation = currencyPresentation
        _displayedPrice = .init(initialValue: currentPrice)
        let currentHour = currentPrice.date.component(.hour, in: calendar)
        _crownValue = .init(initialValue: Double(currentHour))
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(displayedPrice.formattedPrice(.normal, currencyPresentation))
                .font(.title)
            Text(displayedPrice.formattedTimeInterval(.normal))
                .font(.subheadline)
            PriceChartView(
                displayedPrice: $displayedPrice,
                currentPrice: currentPrice,
                prices: prices,
                limits: limits,
                currencyPresentation: currencyPresentation,
                useCurrencyAxisFormat: true,
                isChartGestureEnabled: false
            )
            .focusable()
            .digitalCrownRotation(
                detent: $crownValue,
                from: Double(prices.first?.date.component(.hour, in: calendar) ?? 0),
                through: Double(prices.last?.date.component(.hour, in: calendar) ?? 23),
                by: 1,
                sensitivity: .low,
                onChange: { event in
                    let selectedHour = Int(round(event.offset))
                    let selectedPrice = prices.first { price in
                        let priceHour = price.date.component(.hour, in: calendar)
                        return priceHour == selectedHour
                    }
                    if let selectedPrice = selectedPrice, displayedPrice != selectedPrice {
                        displayedPrice = selectedPrice
                    }
                    cancelSelectionResetTimer()
                },
                onIdle: {
                    scheduleSelectionResetTimer(in: .seconds(5)) {
                        displayedPrice = currentPrice
                        crownValue = Double(currentPrice.date.component(.hour, in: calendar))
                    }
                }
            )
        }
    }

    @State private var selectionResetTimer : DispatchSourceTimer?
    private func scheduleSelectionResetTimer(
        in timeout: DispatchTimeInterval,
        handler: @escaping () -> Void
    ) {
        if selectionResetTimer == nil {
            let timerSource = DispatchSource.makeTimerSource(queue: .global())
            timerSource.setEventHandler {
                Task {
                    cancelSelectionResetTimer()
                    handler()
                }
            }
            selectionResetTimer = timerSource
            timerSource.resume()
        }
        selectionResetTimer?.schedule(
            deadline: .now() + timeout,
            repeating: .infinity,
            leeway: .milliseconds(50)
        )
    }

    private func cancelSelectionResetTimer() {
        selectionResetTimer?.cancel()
        selectionResetTimer = nil
    }

}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .mockLimits,
            currencyPresentation: .automatic
        )
    }
}

