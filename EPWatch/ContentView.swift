//
//  ContentView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

struct ContentView: View {

    @EnvironmentObject private var state: AppState

    @State private var showsSettings: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if let currentPrice = state.currentPrice {
                    PriceView(
                        currentPrice: currentPrice,
                        prices: state.prices.filterInSameDayAs(currentPrice),
                        limits: state.priceLimits,
                        currencyPresentation: state.currencyPresentation
                    )
                    .frame(minHeight: 200)
                } else {
                    HStack {
                        Spacer()
                        ProgressView("Fetching prices...")
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .frame(minHeight: 200)
                }
            }
            .navigationTitle("Electricity price")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showsSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .bold()
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showsSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.mocked)
    }
}
