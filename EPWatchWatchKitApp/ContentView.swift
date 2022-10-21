//
//  ContentView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore
import Charts

struct ContentView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        if let currentPrice = state.currentPrice {
            NavigationStack {
                TabView {
                    PriceView(
                        currentPrice: currentPrice,
                        prices: state.prices.filterInSameDayAs(currentPrice)
                    )
                    SettingsView()
                }
                .tabViewStyle(.page)
            }
        } else {
            Text("Updating prices...")
                .padding()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.mocked)
    }
}
