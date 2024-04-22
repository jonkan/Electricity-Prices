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
            SettingsSection()
            Section {
                BasicSettingsNavigationLink(
                    title: String(localized: "Chart"),
                    values: PriceChartStyle.allCases,
                    currentValue: $state.chartStyle,
                    displayValue: { $0.title }
                )
                .accessibilityIdentifier("chart")
                BasicSettingsNavigationLink(
                    title: String(localized: "View Mode"),
                    values: PriceChartViewMode.allCases,
                    currentValue: $state.chartViewMode,
                    displayValue: { $0.title }
                )
                .accessibilityIdentifier("viewMode")
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
