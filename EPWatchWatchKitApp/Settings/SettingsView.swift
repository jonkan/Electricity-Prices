//
//  SettingsView.swift
//  EPWatchWatchKitApp
//
//  Created by Jonas Bromö on 2022-09-14.
//

import SwiftUI
import EPWatchCore

struct SettingsView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                NavigationLink("Price area") {
                    PriceAreaSettingsView(
                        priceAreas: state.region.priceAreas,
                        priceArea: $state.priceArea
                    )
                    .navigationTitle("Price area")
                }
            }
        }
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.mocked)
    }
}

