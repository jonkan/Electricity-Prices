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
        Toggle(isOn: .constant(true)) {
            Text("Use \(state.currency.subdivision.name)")
        }
        BasicSettingsNavigationLink(
            title: "Currency sign",
            values: CurrencyPresentation.allCases,
            currentValue: $state.currencyPresentation,
            displayValue: { value in
                switch value {
                case .natural: return "Natural (\(state.currency.sign)/\(state.currency.subdivision.sign))"
                case .subdivided: return "\(state.currency.subdivision.name) (\(state.currency.subdivision.sign))"
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
