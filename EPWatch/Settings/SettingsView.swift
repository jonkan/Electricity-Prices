//
//  SettingsView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

struct SettingsView: View {

    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            SettingsSection()
            if let currentPrice = state.currentPrice {
                Section {
                    NavigationLink {
                        PriceAdjustmentSettingsView(
                            pricePresentation: $state.pricePresentation,
                            currentPrice: currentPrice,
                            currency: state.currency
                        )
                        .navigationTitle("Price adjustment")
                    } label: {
                        HStack {
                            Text("Price adjustment")
                            Spacer()
                            Text(state.pricePresentation.adjustment.isEnabled ? "Enabled" : "Disabled")
                        }
                    }
                }
            }
            Section {
                NavigationLink {
                    SupportSettingsView()
                        .navigationTitle("Support")
                } label: {
                    Text("Support")
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
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
