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
    @EnvironmentObject private var watchSyncManager: WatchSyncManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            SettingsSection()
            Section {
                BasicSettingsNavigationLink(
                    title: "Chart",
                    values: PriceChartStyle.allCases,
                    currentValue: $state.chartStyle,
                    displayValue: { $0.title.localized }
                )
                if let currentPrice = state.currentPrice {
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
            if watchSyncManager.isSyncSupported || isSwiftUIPreview() {
                Section {
                    Toggle(isOn: $watchSyncManager.isAppContextSyncEnabled) {
                        Text("Sync with the watch app")
                    }
                } footer: {
                    if watchSyncManager.hasUnsyncedAppContextChanges {
                        if watchSyncManager.isSyncing {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Syncing...")
                            }
                        } else if let error = watchSyncManager.syncError {
                            Text(error.localizedDescription)
                        } else {
                            Text("Changes waiting to sync...")
                        }
                    } else {
                        Text("The watch app is up-to-date.")
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
        .environmentObject(WatchSyncManager.mocked)
    }
}
