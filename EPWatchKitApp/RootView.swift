//
//  RootView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore
import Charts

struct RootView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        if let currentPrice = state.currentPrice {
            NavigationStack {
                TabView {
                    PriceView(
                        currentPrice: currentPrice,
                        prices: state.prices.filterInSameDayAs(currentPrice),
                        limits: state.priceLimits,
                        currencyPresentation: state.currencyPresentation
                    )
                    SettingsView()
                }
                .tabViewStyle(.page)
            }
        } else {
            Text("Fetching prices...")
                .padding()
        }
    }

}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState.mocked)
    }
}
