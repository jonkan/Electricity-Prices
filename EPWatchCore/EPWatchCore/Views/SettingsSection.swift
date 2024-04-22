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
                title: String(localized: "Region", bundle: .module),
                values: Region.allEnabled.localizedSorted(),
                currentValue: $state.region,
                displayValue: { $0.name }
            )
            .accessibilityIdentifier("region")
            if let region = state.region {
                BasicSettingsNavigationLink(
                    title: String(localized: "Price area", bundle: .module),
                    values: region.priceAreas,
                    currentValue: $state.priceArea,
                    displayValue: { $0.title }
                )
                .accessibilityIdentifier("priceArea")
            }
            BasicSettingsNavigationLink(
                title: String(localized: "Currency", bundle: .module),
                values: Currency.allCases,
                currentValue: $state.currency,
                displayValue: { $0.name }
            )
            .accessibilityIdentifier("currency")
            BasicSettingsNavigationLink(
                title: String(localized: "Unit", bundle: .module),
                values: CurrencyPresentation.allCases,
                currentValue: $state.pricePresentation.currencyPresentation,
                displayValue: { value in
                    switch value {
                    case .automatic: return String(localized: "Automatic", bundle: .module)
                    case .subdivided: return "\(state.currency.subdivision.name) (\(state.currency.subdivision.symbol))"
                    }
                }
            )
            .accessibilityIdentifier("unit")
        } footer: {
            switch state.pricePresentation.currencyPresentation {
            case .automatic:
                VStack(alignment: .leading) {
                    Text("\(state.currency.subdivision.name) is used if the price is lower than \(state.currency.formatted(1, .normal, .automatic)).", bundle: .module)
                    Text("Widgets always show prices in \("\(state.currency.shortNamePlural.lowercased()) (\(state.currency.symbol))").", bundle: .module)
                }
            case .subdivided:
                Text("\(state.currency.subdivision.name) is always used.", bundle: .module)
            }
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
