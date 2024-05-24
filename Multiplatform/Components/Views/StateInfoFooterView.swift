//
//  StateInfoFooterView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-10-24.
//

import SwiftUI
import EPWatchCore

struct StateInfoFooterView: View {

    let priceArea: PriceArea?
    let region: Region?
    let exchangeRate: ExchangeRate?
    var hideWithoutTaxesOrFeesDisclamer: Bool = false

    var body: some View {
        Grid(alignment: .topLeading) {
            if let priceArea = priceArea, let region = region {
                GridRow {
                    Text("Price area")
                        .gridColumnAlignment(.trailing)
                    Text("\(priceArea.title + ", " + region.name)")
                        .bold()
                }
            }
            if let exchangeRate = exchangeRate,
               exchangeRate.to != .EUR,
               let formattedRate = exchangeRate.formattedRate() {
                GridRow {
                    Text("Exchange rate")
                        .gridColumnAlignment(.trailing)
                    VStack(alignment: .leading) {
                        Text("\(formattedRate + " " + exchangeRate.to.name + "/" + exchangeRate.from.name)")
                            .bold()
                        Text("ECB closing price \(exchangeRate.formattedDate())")
                    }
                }
            }
            Divider()
                .gridCellUnsizedAxes([.horizontal, .vertical])
            Text("Prices are ", comment: "Substring of \"Prices are per kWh\"") +
            Text("per kWh", comment: "Substring of \"Prices are per kWh\"").bold() +
            (
                hideWithoutTaxesOrFeesDisclamer
                ? Text(".")
                : Text(", without taxes or fees.")
            )
        }
        .font(.caption)
        .frame(maxWidth: .infinity)
    }

}

struct StateInfoFooterView_Previews: PreviewProvider {
    static var previews: some View {
        StateInfoFooterView(
            priceArea: Region.sweden.priceAreas.first,
            region: .sweden,
            exchangeRate: .mockedSEK
        )
    }
}
