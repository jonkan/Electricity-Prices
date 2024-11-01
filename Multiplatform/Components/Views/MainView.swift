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

    var body: some View {
        NavigationStack {
            List {
                if let currentPrice = state.currentPrice,
                   let cheapestHours = state.cheapestHours {
                    Section {
                        PriceView(
                            currentPrice: currentPrice,
                            prices: state.prices.filterForViewMode(state.chartViewMode),
                            limits: state.priceLimits,
                            pricePresentation: state.pricePresentation,
                            chartStyle: state.chartStyle,
                            cheapestHours: cheapestHours
                        )
                        .frame(minHeight: 200)
                    } footer: {
                        StateInfoFooterView(
                            priceArea: state.priceArea,
                            region: state.region,
                            exchangeRate: state.exchangeRate,
                            hideWithoutTaxesOrFeesDisclamer: state.pricePresentation.adjustment.isEnabled
                        )
                    }
                    insightsSection(
                        currentPrice: currentPrice,
                        cheapestHours: cheapestHours
                    )
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

    private func insightsSection(
        currentPrice: PricePoint,
        cheapestHours: CheapestHours
    ) -> some View {
        Section {
            NavigationLink {
                CheapestHoursView(
                    currentPrice: currentPrice,
                    prices: state.prices.filterForViewMode(state.chartViewMode),
                    limits: state.priceLimits,
                    pricePresentation: state.pricePresentation,
                    chartStyle: state.chartStyle,
                    cheapestHours: cheapestHours,
                    cheapestHoursDuration: state.$cheapestHoursDuration
                )
            } label: {
                VStack(alignment: .leading) {
                    let formattedPrice = state.pricePresentation.formattedPrice(
                        cheapestHours,
                        style: .normal
                    )
                    Text("Cheapest \(cheapestHours.duration) hours, \(formattedPrice)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    DateIntervalText(
                        cheapestHours.start,
                        duration: (cheapestHours.duration, .hour),
                        style: .normal
                    )
                }
            }
        } header: {
            Text("Insights")
                .textCase(nil)
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
