//
//  ElectricityPricesApp.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

@main
struct ElectricityPricesApp: App {

    @Environment(\.scenePhase) private var scenePhase
    private let appState: AppState
    private let watchSyncManager: WatchSyncManager
    private let shareLogsState: ShareLogsState

    init() {
#if DEBUG
        LogDebugInformation()
#endif
        appState = .shared
        watchSyncManager = WatchSyncManager(appState: appState)
        shareLogsState = ShareLogsState(watchSyncManager: watchSyncManager)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(watchSyncManager)
                .environmentObject(shareLogsState)
        }
        .onChange(of: scenePhase) {
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (scenePhase == .active)
        }
    }
}
