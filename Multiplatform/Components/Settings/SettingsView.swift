//
//  SettingsView.swift
//  Core
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import Core

struct SettingsView: View {

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var watchSyncManager: WatchSyncManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var isShowingPurchaseView: Bool = false

    var body: some View {
        NavigationStack {
            List {
                SettingsSection()
                Section("Display") {
                    BasicSettingsNavigationLink(
                        title: String(localized: "Chart"),
                        values: PriceChartStyle.mainStyles,
                        currentValue: $state.chartStyle,
                        displayValue: { $0.title }
                    )
                    .accessibilityIdentifier("chart")
                    proFeature {
                        BasicSettingsNavigationLink(
                            title: String(localized: "View Mode"),
                            values: PriceChartViewMode.allCases,
                            currentValue: $state.chartViewMode,
                            displayValue: { $0.title }
                        )
                        .accessibilityIdentifier("viewMode")
                    }
                    if let currentPrice = state.currentPrice {
                        proFeature {
                            NavigationLink {
                                PriceLimitsSettingsView(
                                    limits: $state.priceLimits,
                                    currentPrice: currentPrice,
                                    prices: state.prices.filterForViewMode(state.chartViewMode),
                                    pricePresentation: state.pricePresentation,
                                    chartStyle: state.chartStyle
                                )
                                .navigationTitle("Price Limits")
                            } label: {
                                Text("Price Limits")
                            }
                            .accessibilityIdentifier("priceLimits")
                        }
                        proFeature {
                            NavigationLink {
                                PriceAdjustmentSettingsView(
                                    pricePresentation: $state.pricePresentation,
                                    chartStyle: $state.chartStyle,
                                    currentPrice: currentPrice,
                                    limits: state.priceLimits,
                                    prices: state.prices
                                )
                                .navigationTitle("Price Adjustment")
                            } label: {
                                HStack {
                                    Text("Price Adjustment")
                                    Spacer()
                                    Text(state.pricePresentation.adjustment.isEnabled ? "Enabled" : "Disabled")
                                }
                            }
                            .accessibilityIdentifier("priceAdjustment")
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
                whatsNewSection
                Section {
                    if !store.hasPurchasedProVersion {
                        Button {
                            isShowingPurchaseView = true
                        } label: {
                            Text("Unlock Pro")
                        }
                    } else {
                        Button("Rate This App", systemImage: "star") {
                            // swiftlint:disable:next line_length
                            let writeReviewURL = URL(string: "https://apps.apple.com/app/id1644399828?action=write-review")!
                            openURL(writeReviewURL)
                        }
                    }
                }
                Section {
                    NavigationLink {
                        SupportSettingsView()
                            .navigationTitle("Support")
                    } label: {
                        Text("Support", comment: "Support is for reporting problems")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("done")
                }
            }
            .sheet(isPresented: $isShowingPurchaseView) {
                if store.hasPurchasedProVersion {
                    Log("Purchase view dismissed: Pro purchased")
                } else {
                    Log("Purchase view dismissed: No purchase")
                }
            } content: {
                PurchaseView()
            }
        }
    }

    @ViewBuilder
    private func proFeature<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if store.hasPurchasedProVersion || isRunningForSnapshots() {
            content()
        } else {
            HStack {
                Image(systemName: "lock")
                content()
                    .disabled(true)
            }
            .onTapGesture {
                isShowingPurchaseView = true
            }
        }
    }

    private var whatsNewSection: some View {
        Section {
            Button(
                String(
                    localized: "View on Instagram",
                    comment: "Prefer translations that imply ‘viewing’ rather than ‘watching’ or ‘looking at’."
                ),
                systemImage: "link"
            ) {
                let writeReviewURL = URL(string: "https://www.instagram.com/electricityprices/")!
                openURL(writeReviewURL)
                state.lastVisitedNewsDate = .now
            }
            .badge(state.isBadgeVisible ? 1 : 0)
            .badgeProminence(.increased)
        } header: {
            // swiftlint:disable:next line_length
            Text("What's new", comment: "Section title for release notes or updates. Prefer a translation that conveys ‘News’ or ‘Updates’ rather than a literal ‘What is new’ question.")
        }
    }

}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AppState.mocked)
    .environmentObject(Store.mockedInitial)
    .environmentObject(WatchSyncManager.mocked)
}

#Preview("Pro") {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AppState.mocked)
    .environmentObject(Store.mockedProVersion)
    .environmentObject(WatchSyncManager.mocked)
}
