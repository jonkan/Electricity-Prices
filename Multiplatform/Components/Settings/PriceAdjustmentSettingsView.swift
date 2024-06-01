//
//  PriceAdjustmentSettingsView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2023-09-22.
//

import SwiftUI
import EPWatchCore

struct PriceAdjustmentSettingsView: View {

    @Binding var pricePresentation: PricePresentation
    let currentPrice: PricePoint
    let currency: Currency

    static let decimalNumberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.zeroSymbol = ""
        return nf
    }()

    var body: some View {
        List {
            Section {
                Toggle(isOn: $pricePresentation.adjustment.isEnabled) {
                    Text("Enabled")
                }
            } footer: {
                Text("Adjust the price by adding VAT and fees to estimate what you actually pay for your electricity.")
            }
            if pricePresentation.adjustment.isEnabled {
                feesSection
                multiplierSection
                clampNegativePricesToZeroSection
                calculationSection
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }

    var feesSection: some View {
        Section {
            ForEach($pricePresentation.adjustment.addends) { addend in
                addendRow(addend, currencySubdivisions: currency.subdivision.subdivisions)
            }
            .onDelete(perform: { indexSet in
                withAnimation {
                    pricePresentation.adjustment.addends.remove(atOffsets: indexSet)
                }
            })
            Button {
                withAnimation {
                    pricePresentation.adjustment.addAddend()
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
            Toggle(isOn: $pricePresentation.adjustment.clampNegativePricesToZero) {
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
            currencyPresentation: pricePresentation.currencyPresentation,
            adjustment: PriceAdjustment(isEnabled: false)
        )

        // The current price
        var formattedCurrentPrice = unadjustedPresentation.formattedPrice(currentPrice, style: .normal)
        if pricePresentation.adjustment.clampNegativePricesToZero {
            formattedCurrentPrice = "max(0, \(formattedCurrentPrice))"
        }

        // Addends
        let formattedAddends = pricePresentation.adjustment.addends.map { addend in
            unadjustedPresentation.formattedPrice(
                addend.value,
                in: currency,
                style: .normal
            )
        }

        // The result
        let formattedAdjustedPrice = pricePresentation.formattedPrice(currentPrice, style: .normal)

        let multiplierText = Text(pricePresentation.adjustment.multiplier, format: .number)
        let resultText: Text
        if pricePresentation.adjustment.addends.isEmpty {
            resultText = Text("\(formattedCurrentPrice) * \(multiplierText) = \(formattedAdjustedPrice)")
        } else {
            let addendsText = ([formattedCurrentPrice] + formattedAddends).joined(separator: " + ")
            resultText = Text("(\(addendsText)) * \(multiplierText) = \(formattedAdjustedPrice)")
        }

        return resultText
            .multilineTextAlignment(.leading)
            .monospacedDigit()
    }
}

struct PriceAdjustmentSettingsView_Previews: PreviewProvider {

    struct Container: View {
        @State var pricePresentation = PricePresentation(
            adjustment: PriceAdjustment(isEnabled: true)
        )

        var body: some View {
            PriceAdjustmentSettingsView(
                pricePresentation: $pricePresentation,
                currentPrice: .mockPrice4Negative,
                currency: .SEK
            )
        }
    }

    static var previews: some View {
        NavigationStack {
            Container()
        }
    }
}
