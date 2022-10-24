//
//  CurrencyPresentationSettingsView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-23.
//

import SwiftUI

public struct CurrencyPresentationSettingsNavigationLink: View {

    @EnvironmentObject private var state: AppState

    public init() {}

    public var body: some View {
        BasicSettingsNavigationLink(
            title: "Currency symbol",
            values: CurrencyPresentation.allCases,
            currentValue: $state.currencyPresentation,
            displayValue: { value in
                switch value {
                case .automatic: return "Automatic".localized
                case .subdivided: return "\(state.currency.subdivision.name) (\(state.currency.subdivision.symbol))"
                }
            }
        )
    }

}

struct CurrencyPresentationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPresentationSettingsNavigationLink()
            .environmentObject(AppState.mocked)
    }
}
