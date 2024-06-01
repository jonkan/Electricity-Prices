//
//  PriceLimitsSettingsView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2024-03-29.
//

import SwiftUI
import EPWatchCore

struct PriceLimitsSettingsView: View {

    @Binding var limits: PriceLimits
    let currentPrice: PricePoint
    let prices: [PricePoint]
    let pricePresentation: PricePresentation
    let chartStyle: PriceChartStyle

    @State private var editedLimits: PriceLimits
    @State private var lowSliderRange: ClosedRange<Double>
    private let showPriceAdjustmentDisclamer: Bool

    init(
        limits: Binding<PriceLimits>,
        currentPrice: PricePoint,
        prices: [PricePoint],
        pricePresentation: PricePresentation,
        chartStyle: PriceChartStyle
    ) {
        self._limits = limits
        self.currentPrice = currentPrice
        self.prices = prices

        var pricePresentationWithoutAdjustment = pricePresentation
        pricePresentationWithoutAdjustment.adjustment.isEnabled = false
        self.pricePresentation = pricePresentationWithoutAdjustment

        self.chartStyle = chartStyle
        self.editedLimits = limits.wrappedValue
        self.lowSliderRange = 0...max(limits.wrappedValue.currency.priceLimitsStep, limits.wrappedValue.high)

        if pricePresentation.adjustment.isEnabled {
            showPriceAdjustmentDisclamer = true
        } else {
            showPriceAdjustmentDisclamer = false
        }
    }

    var highLabel: some View {
        let label = Text("High", comment: "As in a high price").foregroundStyle(.secondary)
        let value = pricePresentation.formattedPrice(editedLimits.high, in: editedLimits.currency, style: .normal)
        return Text("\(label) \(value)")
            .monospacedDigit()
    }

    var lowLabel: some View {
        let label = Text("Low", comment: "As in a low price").foregroundStyle(.secondary)
        let value = pricePresentation.formattedPrice(editedLimits.low, in: editedLimits.currency, style: .normal)
        return Text("\(label) \(value)")
            .monospacedDigit()
    }

    var body: some View {
        List {
            Section {
                PriceChartView(
                    selectedPrice: .constant(nil),
                    currentPrice: currentPrice,
                    prices: prices,
                    limits: editedLimits,
                    pricePresentation: pricePresentation,
                    chartStyle: chartStyle,
                    showPriceLimitsLines: true
                )
                .frame(minHeight: 100)
                .padding(.vertical)
            }

            Section {
                VStack(alignment: .leading) {
                    highLabel
                    Slider(
                        value: $editedLimits.high,
                        in: editedLimits.currency.priceLimitsRange,
                        step: editedLimits.currency.priceLimitsStep,
                        onEditingChanged: { isEditing in
                            if !isEditing {
                                editedLimits.low = min(editedLimits.low, editedLimits.high)
                                updateLowSliderRange()
                            }
                        }
                    )
                }

                VStack(alignment: .leading) {
                    lowLabel
                    Slider(
                        value: $editedLimits.low,
                        in: lowSliderRange,
                        step: editedLimits.currency.priceLimitsStep,
                        onEditingChanged: { isEditing in
                            if !isEditing {
                                editedLimits.high = max(editedLimits.high, editedLimits.low)
                            }
                        }
                    )
                }
            } header: {
                Text("Limits")
            } footer: {
                if showPriceAdjustmentDisclamer {
                    Text("Your price adjustment is temporarily excluded while you edit these limits.")
                }
            }

            Section {
                Button {
                    editedLimits = editedLimits.currency.defaultPriceLimits
                    updateLowSliderRange()
                } label: {
                    Text("Reset")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onDisappear {
            // Save on dissapear to not spam state updates
            limits = editedLimits
        }
    }

    private func updateLowSliderRange() {
        lowSliderRange = 0...max(editedLimits.currency.priceLimitsStep, editedLimits.high)
    }

}

private struct PriceLimitsSettingsViewPreview: View {
    @State var limits = Currency.SEK.defaultPriceLimits
    var body: some View {
        PriceLimitsSettingsView(
            limits: $limits,
            currentPrice: .mockPrice,
            prices: .mockPricesWithTomorrow,
            pricePresentation: PricePresentation(
                currencyPresentation: .subdivided,
                adjustment: .init(isEnabled: true)
            ),
            chartStyle: .bar
        )
    }
}

#Preview {
    PriceLimitsSettingsViewPreview()
}
