//
//  MainView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

struct MainView: View {

    @EnvironmentObject private var state: AppState
    @State private var showsSettings: Bool = false
    @AppStorage("ShowCheapestHours")
    private var showCheapestHours: Bool = true

    var body: some View {
        NavigationStack {
            List {
                if let currentPrice = state.currentPrice {
                    Section {
                        PriceView(
                            currentPrice: currentPrice,
                            prices: state.prices.filterForViewMode(state.chartViewMode),
                            limits: state.priceLimits,
                            pricePresentation: state.pricePresentation,
                            chartStyle: state.chartStyle,
                            cheapestHours: showCheapestHours ? state.cheapestHours : nil,
                            minChartHeight: 130
                        )
                    }
                    Section {
                        priceRangeTodayRow
                        priceRangeTomorrowRow
                        cheapestHoursRow
                    } header: {
                        Text("Insights")
                            .textCase(nil)
                    } footer: {
                        StateInfoFooterView(
                            priceArea: state.priceArea,
                            region: state.region,
                            exchangeRate: state.exchangeRate,
                            hideWithoutTaxesOrFeesDisclamer: state.pricePresentation.adjustment.isEnabled
                        )
                        .padding(.top, 4)
                    }
                } else if state.isFetching {
                    VStack {
                        ProgressView("Fetching prices...")
                    }
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = state.userPresentableError {
                    Section {
                        errorView(error)
                    } footer: {
                        StateInfoFooterView(
                            priceArea: state.priceArea,
                            region: state.region,
                            exchangeRate: nil
                        )
                    }
                }
            }
            .navigationTitle(AppInfo.bundleDisplayName)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showsSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .accessibilityIdentifier("settings")
                }
            }
            .sheet(isPresented: $showsSettings) {
                SettingsView()
            }
            .refreshable {
                do {
                    try await state.updatePricesIfNeeded()
                } catch {
                    LogError(error)
                }
            }
        }
    }

    @ViewBuilder
    private var cheapestHoursRow: some View {
        if let currentPrice = state.currentPrice,
           let cheapestHours = state.cheapestHours {
            NavigationLink {
                CheapestHoursView(
                    currentPrice: currentPrice,
                    prices: state.prices.filterForViewMode(state.chartViewMode),
                    limits: state.priceLimits,
                    pricePresentation: state.pricePresentation,
                    chartStyle: state.chartStyle,
                    cheapestHours: cheapestHours,
                    cheapestHoursDuration: state.$cheapestHoursDuration,
                    showInMainChart: $showCheapestHours
                )
            } label: {
                CheapestHoursRow(
                    cheapestHours: cheapestHours,
                    pricePresentation: state.pricePresentation,
                    limits: state.priceLimits
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var priceRangeTodayRow: some View {
        if let priceRangeToday = state.priceRangeToday {
            PriceRangeInsightsRow(
                title: "Today",
                priceRange: priceRangeToday,
                currency: state.currency,
                pricePresentation: state.pricePresentation,
                priceLimits: state.priceLimits
            )
        }
    }

    @ViewBuilder
    private var priceRangeTomorrowRow: some View {
        if let priceRangeTomorrow = state.priceRangeTomorrow {
            PriceRangeInsightsRow(
                title: "Tomorrow",
                priceRange: priceRangeTomorrow,
                currency: state.currency,
                pricePresentation: state.pricePresentation,
                priceLimits: state.priceLimits
            )
        }
    }

    private func errorView(_ error: UserPresentableError) -> some View {
        VStack {
            Image(systemName: "x.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
                .frame(height: 50)
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

}

#Preview {
    MainView()
        .environmentObject(AppState.mocked)
        .environmentObject(Store.mockedProVersion)
        .environmentObject(WatchSyncManager.mocked)
}

#Preview("Error") {
    MainView()
        .environmentObject(AppState.mockedWithError)
        .environmentObject(Store.mockedInitial)
        .environmentObject(WatchSyncManager.mocked)
}
