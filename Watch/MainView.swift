//
//  RootView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI
import EPWatchCore
import Charts

struct MainView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationStack {
            TabView {
                mainTab
                if state.chartViewMode != .todayAndTomorrow {
                    tomorrowTab
                }
                SettingsView()
            }
            .tabViewStyle(.page)
        }
    }

    @ViewBuilder
    var mainTab: some View {
        if let currentPrice = state.currentPrice {
            PriceView(
                currentPrice: currentPrice,
                prices: state.prices.filterForViewMode(state.chartViewMode),
                limits: state.priceLimits,
                pricePresentation: state.pricePresentation,
                chartStyle: state.chartStyle
            )
        } else if state.isFetching {
            ProgressView("Fetching prices...")
        } else if let error = state.userPresentableError {
            errorView(error)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    var tomorrowTab: some View {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        let tomorrowsPrices = state.prices.filterInSameDay(as: tomorrow)
        if tomorrowsPrices.count == 24 {
            PriceView(
                currentPrice: tomorrowsPrices[0],
                prices: tomorrowsPrices,
                limits: state.priceLimits,
                pricePresentation: state.pricePresentation,
                chartStyle: state.chartStyle
            )
        } else {
            Text("Tomorrows prices not yet available.")
        }
    }

    func errorView(_ error: UserPresentableError) -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(systemName: "x.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(height: 50)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
    }

}

#Preview {
    MainView()
        .environmentObject(AppState.mocked)
}

#Preview("Error") {
    MainView()
        .environmentObject(AppState.mockedWithError)
}
