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
        ScrollView {
            NavigationLink {
                RegionSettingsView(
                    regions: Region.allCases,
                    region: $state.region
                )
                .navigationTitle("Region")
            } label: {
                HStack {
                    Text("Region")
                    Spacer()
                    Text(state.region?.name ?? "")
                }
            }
            if let region = state.region {
                NavigationLink {
                    PriceAreaSettingsView(
                        priceAreas: region.priceAreas,
                        priceArea: $state.priceArea
                    )
                    .navigationTitle("Price area")
                } label: {
                    HStack {
                        Text("Price area")
                        Spacer()
                        Text(state.priceArea?.title ?? "")
                    }
                }
            }
        }
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
        .environmentObject(AppState.mocked)
    }
}

