//
//  SettingsView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-23.
//

import SwiftUI

public struct SettingsSection: View {

    @EnvironmentObject private var state: AppState

    public init() {}

    public var body: some View {
        Section {
            BasicSettingsNavigationLink(
                title: "Region",
                values: Region.allEnabled.localizedSorted(),
                currentValue: $state.region,
                displayValue: { $0.name.localized }
            )
            if let region = state.region {
                BasicSettingsNavigationLink(
                    title: "Price area",
                    values: region.priceAreas,
                    currentValue: $state.priceArea,
                    displayValue: { $0.title }
                )
            }
            BasicSettingsNavigationLink(
                title: "Currency",
                values: Currency.allCases,
                currentValue: $state.currency,
                displayValue: { $0.name.localized }
            )
            BasicSettingsNavigationLink(
                title: "Unit",
                values: CurrencyPresentation.allCases,
                currentValue: $state.currencyPresentation,
                displayValue: { value in
                    switch value {
                    case .automatic: return "Automatic".localized
                    case .subdivided: return "\(state.currency.subdivision.name.localized) (\(state.currency.subdivision.symbol))"
                    }
                }
            )
        } footer: {
            switch state.currencyPresentation {
            case .automatic:
                VStack(alignment: .leading) {
                    Text("\(state.currency.subdivision.name) is used if the price is lower than \(state.currency.formatted(1, .normal, .automatic)).")
                    Text("Widgets always show prices in \("\(state.currency.shortNamePlural.localized.lowercased()) (\(state.currency.symbol))").")
                }
            case .subdivided:
                Text("\(state.currency.subdivision.name) is always used.")
            }
        }

        Section {
            BasicSettingsNavigationLink(
                title: "Chart",
                values: PriceChartStyle.allCases,
                currentValue: $state.chartStyle,
                displayValue: { $0.title.localized }
            )
        }
    }

}

struct SettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SettingsSection()
        }
        .environmentObject(AppState.mocked)
    }
}
