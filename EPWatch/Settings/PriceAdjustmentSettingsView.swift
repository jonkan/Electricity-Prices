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

    static let multiplierFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        return nf
    }()

    var body: some View {
        List {
            Section {
                Toggle(isOn: $pricePresentation.adjustment.isEnabled) {
                    Text("Enabled")
                }
            }
            if pricePresentation.adjustment.isEnabled {
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
                    Text("Addends")
                } footer: {
                    if pricePresentation.adjustment.addends.isEmpty {
                        Text("Specify prices in ") +
                        Text("\(currency.subdivision.name.localized)/kWh").bold() +
                        Text(".")
                    }
                }
                Section {
                    multiplierRow
                }
                Section {
                    calculationRow
                } header: {
                    Text("Calculation")
                } footer: {
                    Text("Prices are ") +
                    Text("per kWh").bold() +
                    Text(".")
                }
            }
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
                "Addend name",
                text: addend.title,
                prompt: Text("Addend")
            )
            TextField(
                "Addend",
                value: subdividedAddend,
                format: .number,
                prompt: Text("Addend")
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
        }
    }

    var multiplierRow: some View {
        HStack {
            Text("Multiplier")
            TextField(
                "Multiplier",
                value: $pricePresentation.adjustment.multiplier,
                formatter: Self.multiplierFormatter,
                prompt: Text("Multiplier")
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)

        }
    }

    var calculationRow: some View {
        let unadjustedPresentation = PricePresentation(
            currencyPresentation: pricePresentation.currencyPresentation,
            adjustment: PriceAdjustment(isEnabled: false)
        )

        // The current price
        let formattedCurrentPrice = unadjustedPresentation.formattedPrice(currentPrice, style: .normal)

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

        return HStack {
            Text(pricePresentation.adjustment.addends.isEmpty ? "" : "(") +
            Text(([formattedCurrentPrice] + formattedAddends).joined(separator: " + ")) +
            Text(pricePresentation.adjustment.addends.isEmpty ? " * " : ") * ") +
            Text(pricePresentation.adjustment.multiplier, format: .number) +
            Text(" = ") +
            Text(formattedAdjustedPrice)
        }
        .multilineTextAlignment(.leading)
        .monospacedDigit()
    }

}

struct PriceAdjustmentSettingsView_Previews: PreviewProvider {

    @State static var pricePresentation = PricePresentation(
        adjustment: PriceAdjustment(isEnabled: true)
    )

    static var previews: some View {
        NavigationStack {
            PriceAdjustmentSettingsView(
                pricePresentation: $pricePresentation,
                currentPrice: .mockPrice,
                currency: .SEK
            )
        }
    }
}

