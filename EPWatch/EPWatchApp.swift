//
//  EPWatchApp.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

@main
struct EPWatchApp: App {

    @Environment(\.scenePhase) private var scenePhase

    init() {
#if DEBUG
        LogDebugInformation()
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AppState.shared)
                .environmentObject(ShareLogsState.shared)
        }
        .onChange(of: scenePhase) { phase in
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (phase == .active)
        }
        .backgroundTask(.appRefresh("RefreshPrices")) {
            do {
                try await AppState.shared.updatePricesIfNeeded()
            } catch {
                LogError(error)
            }
        }
    }
}
