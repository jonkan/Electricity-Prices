//
//  PriceAdjustmentSettingsView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2023-09-22.
//

import SwiftUI
import Core

struct PriceAdjustmentSettingsView: View {

    @Binding var pricePresentation: PricePresentation
    @Binding var chartStyle: PriceChartStyle
    let currentPrice: PricePoint
    let limits: PriceLimits
    let prices: [PricePoint]

    @State private var editedPricePresentation: PricePresentation
    @State private var editedChartStyle: PriceChartStyle
    private var priceAdjustmentStyle: Binding<PriceAdjustmentStyle> {
        Binding {
            if case .bar(let style) = editedChartStyle {
                return style
            } else {
                return .off
            }
        } set: { style in
            editedChartStyle = .bar(style)
        }
    }
    private var currency: Currency {
        currentPrice.currency
    }

    private static let decimalNumberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.zeroSymbol = ""
        return nf
    }()

    init(
        pricePresentation: Binding<PricePresentation>,
        chartStyle: Binding<PriceChartStyle>,
        currentPrice: PricePoint,
        limits: PriceLimits,
        prices: [PricePoint]
    ) {
        _pricePresentation = pricePresentation
        _editedPricePresentation = State(initialValue: pricePresentation.wrappedValue)
        _chartStyle = chartStyle
        _editedChartStyle = State(initialValue: chartStyle.wrappedValue)
        self.currentPrice = currentPrice
        self.limits = limits
        self.prices = prices
    }

    var body: some View {
        List {
            Section {
                Toggle(isOn: $editedPricePresentation.adjustment.isEnabled) {
                    Text("Enabled")
                }
            } footer: {
                Text("Adjust the price by adding VAT and fees to estimate what you actually pay for your electricity.")
            }
            if editedPricePresentation.adjustment.isEnabled {
                feesSection
                multiplierSection
                clampNegativePricesToZeroSection
                calculationSection
                appearanceSection
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .onDisappear {
            pricePresentation = editedPricePresentation
            chartStyle = editedChartStyle
        }
    }

    var feesSection: some View {
        Section {
            ForEach($editedPricePresentation.adjustment.addends) { addend in
                addendRow(addend, currencySubdivisions: currency.subdivision.subdivisions)
            }
            .onDelete(perform: { indexSet in
                withAnimation {
                    editedPricePresentation.adjustment.addends.remove(atOffsets: indexSet)
                }
            })
            Button {
                withAnimation {
                    editedPricePresentation.adjustment.addAddend()
                }
            } label: {
                Label("Add", systemImage: "plus.circle")
            }
        } header: {
            Text("Fees")
        } footer: {
            Text("Enter prices in **\(currency.subdivision.name)/kWh**.")
        }
    }

    func addendRow(_ addend: Binding<PriceAdjustment.Addend>, currencySubdivisions: Double) -> some View {
        let subdividedAddend = Binding<Double> {
            addend.value.wrappedValue * currencySubdivisions
        } set: { newValue in
            addend.value.wrappedValue = newValue / currencySubdivisions
        }
        return HStack {
            TextField(
                "Name",
                text: addend.title,
                prompt: Text("Name")
            )
            TextField(
                "Fee",
                value: subdividedAddend,
                formatter: Self.decimalNumberFormatter,
                prompt: Text("Fee")
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
        }
    }

    var multiplierSection: some View {
        Section {
            HStack {
                Text("Multiplier")
                TextField(
                    "Multiplier",
                    value: $pricePresentation.adjustment.multiplier,
                    formatter: Self.decimalNumberFormatter,
                    prompt: Text("Multiplier")
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            }
        } footer: {
            Text("A multiplier of 1.25 increases the price by 25%.")
        }
    }

    var clampNegativePricesToZeroSection: some View {
        Section {
            Toggle(isOn: $editedPricePresentation.adjustment.clampNegativePricesToZero) {
                Text("Clamp negative prices")
            }
        } footer: {
            Text("Negative prices will be clamped to zero.")
        }
    }

    var calculationSection: some View {
        Section {
            calculationRow
        } header: {
            Text("Calculation")
        } footer: {
            Text("Prices are **per kWh**.")
        }
    }

    var calculationRow: some View {
        let unadjustedPresentation = PricePresentation(
            currencyPresentation: editedPricePresentation.currencyPresentation,
            adjustment: PriceAdjustment(isEnabled: false)
        )

        // The current price
        var formattedCurrentPrice = unadjustedPresentation.formattedPrice(currentPrice, style: .normal)
        if editedPricePresentation.adjustment.clampNegativePricesToZero {
            formattedCurrentPrice = "max(0, \(formattedCurrentPrice))"
        }

        // Addends
        let formattedAddends = editedPricePresentation.adjustment.addends.map { addend in
            unadjustedPresentation.formattedPrice(
                addend.value,
                in: currency,
                style: .normal
            )
        }

        // The result
        let formattedAdjustedPrice = editedPricePresentation.formattedPrice(currentPrice, style: .normal)

        let multiplierText = Text(editedPricePresentation.adjustment.multiplier, format: .number)
        let resultText: Text
        if editedPricePresentation.adjustment.addends.isEmpty {
            resultText = Text("\(formattedCurrentPrice) * \(multiplierText) = \(formattedAdjustedPrice)")
        } else {
            let addendsText = ([formattedCurrentPrice] + formattedAddends).joined(separator: " + ")
            resultText = Text("(\(addendsText)) * \(multiplierText) = \(formattedAdjustedPrice)")
        }

        return resultText
            .multilineTextAlignment(.leading)
            .monospacedDigit()
    }

    var appearanceSection: some View {
        Section {
            PriceChartView(
                selectedPrice: .constant(nil),
                currentPrice: currentPrice,
                prices: prices,
                limits: limits,
                pricePresentation: editedPricePresentation,
                chartStyle: editedChartStyle
            )
            .frame(minHeight: 100)
            .padding(.vertical)
            Picker(selection: priceAdjustmentStyle) {
                ForEach(PriceAdjustmentStyle.allCases) {
                    Text($0.title)
                        .tag($0)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .disabled(!editedChartStyle.isBar)
        } header: {
            Text("Visualization")
        } footer: {
            Text("Separates the spot price (bottom) from adjustments (top) in the chart. Only supported in bar charts.")
        }
    }

}

#Preview {
    @Previewable @State var pricePresentation = PricePresentation(
        adjustment: PriceAdjustment(isEnabled: true)
    )
    @Previewable @State var chartStyle: PriceChartStyle = .bar()
    let prices: [PricePoint] = .mockedPricesWithTomorrow2

    NavigationStack {
        PriceAdjustmentSettingsView(
            pricePresentation: $pricePresentation,
            chartStyle: $chartStyle,
            currentPrice: prices[14],
            limits: .mocked,
            prices: prices
        )
    }
    .environment(\.locale, .init(identifier: "en_US"))
}
