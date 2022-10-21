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
        if let currentPrice = state.currentPrice {
            NavigationStack {
                List {
                    PriceView(
                        currentPrice: currentPrice,
                        prices: state.prices.filterInSameDayAs(currentPrice),
                        limits: state.priceLimits
                    )
                    .frame(minHeight: 200)
                }
                .navigationTitle("Electric price")
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
