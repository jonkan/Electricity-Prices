//
//  ElectricityPricesApp.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import Core

@main
struct ElectricityPricesApp: App {

    @Environment(\.scenePhase) private var scenePhase
    private let appState: AppState
    private let store: Store
    private let watchSyncManager: WatchSyncManager
    private let shareLogsState: ShareLogsState

    init() {
#if DEBUG
        LogDebugInformation()
#endif

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            UserDefaults.appGroup.set(true, forKey: "FASTLANE_SNAPSHOT")
        } else {
            UserDefaults.appGroup.set(false, forKey: "FASTLANE_SNAPSHOT")
        }

        appState = .shared
        store = Store()
        watchSyncManager = WatchSyncManager(appState: appState)
        shareLogsState = ShareLogsState(watchSyncManager: watchSyncManager)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .environmentObject(store)
                .environmentObject(watchSyncManager)
                .environmentObject(shareLogsState)
        }
        .onChange(of: scenePhase) {
            Log("Scene phase changed: \(scenePhase)")
            AppState.shared.isTimerRunning = (scenePhase == .active)
        }
    }
}
