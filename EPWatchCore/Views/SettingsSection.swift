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
                values: Region.allCases,
                currentValue: $state.region,
                displayValue: { $0.name }
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
                displayValue: { $0.name }
            )
            CurrencyPresentationSettingsNavigationLink()
        } footer: {
            switch state.currencyPresentation {
            case .natural:
                Text("Widgets will always show prices in \(state.currency.sign)")
            case .subdivided:
                Text("Widgets will always show prices in \(state.currency.subdivision.sign)")
            }
        }
    }

}

struct SettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSection()
    }
}

